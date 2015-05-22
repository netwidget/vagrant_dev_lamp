#!/usr/bin/env bash
base_name="$1"
php_version="5.4"

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
# TODO: fix sed This is returning " unkown option to `s'"
sed -i "s/;error_log = php_errors.log/error_log = '/var/www/$base_name/log/php_errors.log'/" /etc/php.ini

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
echo "---------------------------------------------"
echo "          PHP installation complete          "
echo "---------------------------------------------"
