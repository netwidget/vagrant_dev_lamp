#!/usr/bin/env bash

# Shell provisioner for Apache web server.

# Parameters from Vagrantfile
base_name="${1}"

# Update YUM
#-------------------------------------------------------
yum update -y
yum install -y httpd httpd-devel

# Apache & VirtualHost Environment
#-------------------------------------------------------
# Configure Apache
# # Edit httpd.conf
# Set cache parameters
# Set ServerName of web server
# Add VirtualHost include path
# Uncomment NameVirtualHost port assignment
if grep -q "ServerName ${base_name}" /etc/httpd/conf/httpd.conf; then
  echo "httpd.conf already setup, moving on."
else
  echo "Configuring http.conf file..."
  apache_conf="ServerName ${base_name}
  EnableSendfile off
  Include /etc/httpd/conf.d/*.conf"
  echo "${apache_conf}" >> /etc/httpd/conf/httpd.conf
  sed -i "s/#NameVirtualHost \*:80/NameVirtualHost \*:80/" /etc/httpd/conf/httpd.conf
fi

# Configure Virtual Host
# Check/create project folder and DocumentRoot folder
# Create VirtualHost file for intranet
if [ ! -f /var/www/${base_name}/docroot ]; then
  echo "Creating document root directory for website..."
  mkdir -p /var/www/${base_name}/docroot
  echo "Creating log folder for apache error logs..."
  mkdir -p /var/www/${base_name}/log
  touch favicon.ico
else
  echo "Directory Exists. Moving on..."
fi

# Check/create virtualHost file.
if [ ! -f /etc/httpd/conf.d/10-${base_name}.conf ]; then
  echo "Creating virtualHost file..."
htconfig="<VirtualHost *:80>
  ServerAdmin webmaster@${base_name}
  DocumentRoot /var/www/${base_name}/docroot
  ServerName ${base_name}
  ErrorLog /var/www/${base_name}/log/${base_name}-error_log
  CustomLog /var/www/${base_name}/log/${base_name}-access_log common
  <Directory /var/www/${base_name}/docroot>
    Options Includes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
  </VirtualHost>"
  echo "${htconfig}" > /etc/httpd/conf.d/10-${base_name}.conf
  echo "Virtualhost file has been created for ${base_name}."
else
  echo "Virtualhost file is already create, moving on."
fi

# Set permissions for apache
if grep -q "vagrant:x:501:apache" /etc/group; then
  echo "apache user permissions already added, moving on."
else
  echo "Adding apache to /etc/group vagrant permissions"
  sed -i "s/vagrant:x:501:/vagrant:x:501:apache/" /etc/group
fi

# Set Apache to start on boot.
chkconfig httpd on
sudo service httpd restart

echo "---------------------------------------------"
echo "         Apache installation complete         "
echo "---------------------------------------------"
