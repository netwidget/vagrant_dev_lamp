#!/usr/bin/env bash

# configure php.ini for Drupal requirements
sudo sed -i "s/max_execution_time = 30/max_execution_time = 128/" /etc/php.ini
sudo sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php.ini

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

# Restart apache for php.ini changes to take effect.
sudo service httpd restart

echo "---------------------------------------------"
echo "     Drupal base configuration complete      "
echo "---------------------------------------------"
