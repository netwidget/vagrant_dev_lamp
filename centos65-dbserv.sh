#!/usr/bin/env bash

# Shell provisioner for MySQL database server.

# global variables
# base_name from Vagrant arg: #{vm_name}

# base_name from Vagrant arg: #{vm_name}
base_name="${1}"

# Use base_name as database name
db_name="${base_name}"

db_password="${base_name}"
db_user="${base_name}"
db_host="localhost"
db_port="3306"
db_driver="mysql"
# Database variables wrapped in single quotes for BASH/SQL expansion.
mysql_user="'${base_name}'"
mysql_psswd="'${base_name}'"

# Update YUM
#-------------------------------------------------------
yum update -y
yum install -y mysql mysql-server mysql-devel

# Set mysql to laod and startup
sudo chkconfig mysqld on

# Configure my.cnf file for CMS.
mysql_conf="[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
key_buffer=384M
max_allowed_packet=128M

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid"

if [ -f /etc/my.cnf ]; then
  mv /etc/my.cnf /etc/my.cnf.bak
  echo "my.cnf exits, backing it up..."
  echo "${mysql_conf}" > /etc/my.cnf
  echo "Overwriting my.cnf...."
else
  echo "${mysql_conf}" > /etc/my.cnf
  echo "Copying my.cnf file..."
  echo ""
fi

sudo service mysqld restart

# Set database permissions
echo "Configure MySQL..."
mysql -u root -h ${db_host} -se "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -u root -h ${db_host} -se "FLUSH PRIVILEGES;"

echo "---------------------------------------------"
echo "         Mysql installation complete         "
echo "---------------------------------------------"


