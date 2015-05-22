#!/usr/bin/env bash

# Script to provision a CentOS 6.5 64-bit web server using Vagrant
# written by James Dugger

# Global Variables.
# Leave this varible as is it will get changed in the VagrantFile.
#base_name="$(< /vagrant/base_name.conf)"
base_name="$1"

project_folder="$base_name"
base_folder="var/www"
doc_root="docroot"

# version of PHP to install. Choice of 5.4 or 5.5.
php_version="5.4"

# domain name used in the virtual host config file.
#domain_name=$base_name

# Set for httpd.conf file to avoid apache warning for FDGN.
#servername=$base_name

# Address for DNS resolution in /etc/hosts file.  default set to loopback.
address="127.0.0.1"

# Update YUM
#-------------------------------------------------------
yum update -y
yum install -y vim lsof mysql mysql-server mysql-devel httpd httpd-devel autoconf automake

# Networking / Name resolution
#-------------------------------------------------------
# Turn on networking
# Set networking to start at boot.
sed -i 's/^\(ONBOOT\s*=\s*\).*$/\1yes/' /etc/sysconfig/network-scripts/ifcfg-eth0
ifup eth0
echo "Changed ONBOOT=yes"

# Configure hosts file
# Check for domain name resolution in hosts file
# If not already set add address/name for resolution.
if grep -Fxq "$address $base_name" /etc/hosts
  then
    echo "$base_name is already added to the loopback address."
  else
    cp /etc/hosts /etc/hosts.back
    echo "$address $base_name" >> /etc/hosts
fi

# Apache & VirtualHost Environment
#-------------------------------------------------------
# Configure Apache
# # Edit httpd.conf
# Set cache parameters
# Set ServerName of web server
# Add VirtualHost include path
# Uncomment NameVirtualHost port assignment
apache_conf="ServerName $base_name
EnableSendfile off
Include /etc/httpd/conf.d/*.conf"
echo "$apache_conf" >> /etc/httpd/conf/httpd.conf
sed -i "s/#NameVirtualHost \*:80/NameVirtualHost \*:80/" /etc/httpd/conf/httpd.conf

# Configure Virtual Host
# Check/create project folder and DocumentRoot folder
# Create VirtualHost file for intranet
mkdir -p /$base_folder/$project_folder/$doc_root
mkdir -p /$base_folder/$project_folder/log
htconfig="<VirtualHost *:80>
  ServerAdmin webmaster@$base_name
  DocumentRoot /$base_folder/$project_folder/$doc_root
  ServerName $base_name
  ErrorLog /$base_folder/$project_folder/log/$base_name-error_log
  CustomLog /$base_folder/$project_folder/log/$base_name-access_log common
  <Directory /$base_folder/$project_folder/$doc_root>
    Options Includes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
  </VirtualHost>"

# TODO - conditional to check for existing numerical prefix in vhost config name.
echo "$htconfig" > /etc/httpd/conf.d/10-$base_name.conf
echo "httpd.conf file is updated with <Virtualhost> settings."

# Set permissions for apache
sed -i "s/vagrant:x:501:/vagrant:x:501:apache/" /etc/group

# Restart Apache
service httpd start
echo "Apache installed and configured"

# Set Apache to start on boot.
chkconfig httpd on

# Install & Configure PHP
#-------------------------------------------------------
# Add Webtatic repo to PHP Versions 5.4 and 5.5
rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm;

# Install PHP Version - match case of defined global variable.
case $php_version in
  "5.5" ) yum install php55w php55w-common php55w-opcache php55w-devel php55w-mbstring php55w-mcrypt php55w-mysql php55w-xml php55w-ldap php55w-soap php55w-pdo php55w-pecl-xdebug -y; ;;
  "5.4" ) yum install php54w php54w-common php54w-opcache php54w-devel php54w-mbstring php54w-mcrypt php54w-gd php54w-mysql php54w-xml php54w-ldap php54w-soap php54w-pdo php54w-pecl-xdebug -y; ;;
esac

# Configure php.ini
# Uncomment php_errors log
sed -i "s/;error_log = php_errors.log/error_log = '$base_folder/$project_folder/log/php_errors.log'/" /etc/php.ini

# Add xdebug to php.ini
# Set executution bit
# TODO - test xdebug settings.
# The following line conficts with a compiled version in php54w-
# it was removed from the [xdebug] insert below.
# zend_extension=/usr/lib64/php/modules/xdebug.so
debug="
[xdebug]
xdebug.remote_autostart=off
xdebug.remote_enable=on
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_host=localhost
xdebug.remote_port=9000"
echo "${debug}" >> /etc/php.ini
chmod +x /usr/lib64/php/modules/xdebug.so
echo "xdebug installed and configured"
echo "PHP Installed"

# Drupal - DRUSH & Settings
#-------------------------------------------------------
cd /usr/local/share/
wget http://ftp.drupal.org/files/projects/drush-8.x-6.0-rc4.tar.gz
tar -zxvf drush-8.x-6.0-rc4.tar.gz
rm -f drush-8.x-6.0-rc4.tar.gz
cd ~
ln -s /usr/local/share/drush/drush /usr/local/bin/drush
cd /usr/local/share/drush/lib
wget http://download.pear.php.net/package/Console_Table-1.1.3.tgz
tar -zxvf Console_Table-1.1.3.tgz
rm -f Console_Table-1.1.3.tgz

# Configure settings.php
if [ ! -f "/$base_folder/$project_folder/$doc_root/sites/default/settings.php" ] && [ -f /vagrant/settings.php ]; then
  echo "Congifuring settings.php file..."
  sed -i "s/'database' => 'database'/'database' => '$db_name'/" /vagrant/settings.php
  sed -i "s/'username' => 'root'/'username' => '$db_user'/" /vagrant/settings.php
  sed -i "s/'password' => 'password'/'password' => '$db_password'/" /vagrant/settings.php
  sed -i "s/'host' => 'localhost'/'host' => '$db_host'/" /vagrant/settings.php
  sed -i "s/'port' => ''/'port' => '$db_port'/" /vagrant/settings.php
  sed -i "s/'driver' => 'mysql'/'driver' => '$db_driver'/" /vagrant/settings.php
  sed -i "s/'prefix' => ''/'prefix' => '$db_prefix'/" /vagrant/settings.php
  echo "Copying settings.php file from /vagrant/ directory..."
  cp /vagrant/settings.php /$base_folder/$project_folder/$doc_root/sites/default/settings.php
else
    echo "/$base_folder/$project_folder/settings.php already exits. Moving on..."
fi

# Configure human inteterst bar (Laravel database settings.)
if [ ! -f "/$base_folder/$project_folder/$doc_root/interest-bar/application/config/database.php" ] && [ -f /vagrant/database.php ]; then
  # configure database.php for human-interest-bar.
  sed -i "s/'database' => 'database'/'database' => '$db_name'/g" /vagrant/database.php
  sed -i "s/'username' => 'root'/'username' => '$db_user'/g" /vagrant/database.php
  sed -i "s/'password' => 'password'/'password' => '$db_password'/g" /vagrant/database.php
  sed -i "s/'host' => 'localhost'/'host' => '$db_host'/g" /vagrant/database.php
  sed -i "s/'port' => ''/'port' => '$db_port'/g" /vagrant/database.php
  sed -i "s/'driver' => 'mysql'/'driver' => '$db_driver'/g" /vagrant/database.php
  sed -i "s/'prefix' => ''/'prefix' => '$db_prefix'/g" /vagrant/database.php
  cp /vagrant/database.php /$base_folder/$project_folder/$doc_root/interest-bar/application/config/database.php
else
    echo "/$base_folder/$project_folder/database.php already exits. Moving on..."
fi

# install the files directory for Drupal.
if [ ! -d "/$base_folder/$project_folder/$doc_root/sites/default/files" ] && [ -f "/$base_folder/$project_folder/files.tar" ]; then
  # configure database settings in settings.php
  # TODO - Fix the tar funciton; correct pathing.
  mv /vargrant/files.tar "/$base_folder/$project_folder/$doc_root/sites/default/files"
else
  echo "/$base_folder/$project_folder/files.tar does not exits."
fi

# IP tables configuration
#-------------------------------------------------------
/etc/init.d/iptables stop
iptables -F
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 995 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables-save | sudo tee /etc/sysconfig/iptables
service iptables restart
echo "iptables configured"

service httpd start

echo "---------------------------------------------"
echo "               SYSTEM COMPLETE!              "
echo "---------------------------------------------"
