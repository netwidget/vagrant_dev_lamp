#!/usr/bin/env bash

# Shell provisioner Apache Solr server.

# global variables
# base_name from Vagrant arg: #{vm_name}
base_name="$1"
solr_version="4.3.0"
tomcat_vers="7.0.61"


# Update YUM
#-------------------------------------------------------
yum update -y
yum install -y java-1.7.0-openjdk

# Install and config Tomcate
#-------------------------------------------------------

# Create a low level user for tomcat
useradd -Mb /usr/local tomcat

cd /usr/local/src

# Download and installation of Tomcat
wget http://mirror.tcpdiag.net/apache/tomcat/tomcat-7/v$tomcat_vers/bin/apache-tomcat-$tomcat_vers.tar.gz

tar -C /usr/local -zxf /usr/local/src/apache-tomcat-$tomcat_vers.tar.gz
mv /usr/local/apache-tomcat-$tomcat_vers /usr/local/tomcat

# Change port number to Tomcat.
sudo sed -i s/8080/8983/g /usr/local/tomcat/conf/server.xml
/g /usr/local/tomcat/conf/server.xml

# Change ownership of tomcat.
chown -R tomcat:tomcat /usr/local/tomcat
sudo -u tomcat /usr/local/tomcat/bin/startup.sh

# Install and configure Solr
#-------------------------------------------------------
cd /var/www/$base_name
wget http://archive.apache.org/dist/lucene/solr/$solr_version/solr-$solr_version.tgz
# Extract solr folders.
tar -xvf solr-$solr_version.tgz

# Copy the log4jconfig file to tomcat.
cp solr-$solr_version/dist/solrj-lib/* /usr/local/tomcat/lib/

# Copy the log4j config to tomcat config.
cp solr-$solr_version/example/resources/log4j.properties /usr/local/tomcat/conf/

# copy the Solr webapp file to tomcat
cp solr-$solr_version/dist/solr-$solr_version.war /usr/local/tomcat/webapps/solr.war

# Create the Solr context file.
cat > /usr/local/tomcat/conf/Catalina/localhost/solr.xml <<'TBLOCK'
<Context docBase="/usr/local/tomcat/webapps/solr.war" debug="0" crossContext="true">
  <Environment name="solr/home" type="java.lang.String" value="/usr/local/tomcat/solr" override="true" />
</Context>
TBLOCK

# Create Solr directory
mkdir -p /usr/local/tomcat/solr
cp -r solr-$solr_version/example/solr/collection1/conf /usr/local/tomcat/solr/

#mv /var/www/$base_name/solr-$solr_version /opt/solr

# Get Drupal 7 apachesolr module. 
wget http://ftp.drupal.org/files/projects/apachesolr-7.x-1.7.tar.gz
tar -xvf apachesolr-*.tar.gz

# Copy drupal configration files to solr.
rsync -av apachesolr/solr-conf/solr-4.x/ /usr/local/tomcat/solr/conf/

# Add solr_xml file.
cat > /usr/local/tomcat/solr/solr.xml <<'TBLOCK'
<?xml version="1.0" encoding="UTF-8" ?>
<solr persistent="false">
  <cores adminPath="/admin/cores">
    <core name="drupal" instanceDir="drupal" />
  </cores>
</solr>
TBLOCK

# Create the drupal solr core directory
mkdir /usr/local/tomcat/solr/drupal
cp -r /usr/local/tomcat/solr/conf /usr/local/tomcat/solr/drupal/

# Install Tika 
#--------------------------------------------

# Download Tika from Apache.
# mkdir -p /usr/local/tomcat/solr/lib

# Extract Tar into the /solr/lib
#rsync -av /usr/local/tomcat/solr/contrib/extraction/ /usr/local/tomcat/solr/lib/

# Download Tika from Apache.
mkdir -P /var/www/$base_name/docroot/tmp
cd /var/www/$base_name/docroot/tmp
wget http://archive.apache.org/dist/tika/tika-app-1.3.jar

# Stop tomcat and set permissions.
/usr/local/tomcat/bin/shutdown.sh 
chown -R tomcat:tomcat /usr/local/tomcat
sudo -u tomcat /usr/local/tomcat/bin/startup.sh

# Create init.d script to autstart tomcat
cat > /etc/init.d/tomcat <<'TBLOCK'
#!/bin/sh
#
# Startup script for Tomcat Servlet Engine
#
# chkconfig: 345 86 14
# description: Tomcat Servlet Engine
# processname: tomcat

### BEGIN INIT INFO
# Provides: tomcat
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short Description: Tomcat Servlet Engine
# Description: Tomcat Servlet Engine
### END INIT INFO

umask 002

NAME=tomcat

#### The following variables can be overwritten in /etc/default/$NAME
#### See /usr/local/tomcat/bin/catalina.sh for a complete list of available variables
#### and their definitions.

TOMCAT_USER=tomcat
CATALINA_HOME=/usr/local/$NAME
CATALINA_BASE=$CATALINA_HOME
CATALINA_OUT=$CATALINA_BASE/logs/catalina.out
#CATALINA_OPTS="-Dcom.sun.management.snmp.port=9983 -Dcom.sun.management.snmp.acl.file=$CATALINA_HOME/conf/snmp.acl -Dcom.sun.management.snmp.interface=0.0.0.0"
CATALINA_TMPDIR=$CATALINA_BASE/temp
JAVA_HOME=/usr
JRE_HOME=$JAVA_HOME
JAVA_OPTS="-Djava.awt.headless=true"
JAVA_ENDORSED_DIRS=$CATALINA_HOME/endorsed
CATALINA_PID=$CATALINA_HOME/bin/$NAME.pid
#LOGGING_CONFIG=
#LOGGING_MANAGER=

##### End of variables that can be overwritten in /etc/default/$NAME #####

# Overwrite settings from the default file
if [ -f "/etc/default/$NAME" ]; then
    . /etc/default/$NAME
fi

export CATALINA_HOME CATALINA_BASE CATALINA_OUT CATALINA_OPTS CATALINA_TMPDIR JAVA_HOME JRE_HOME JAVA_OPTS JAVA_ENDORSED_DIRS CATALINA_PID LOGGING_CONFIG LOGGING_MANAGER

RETVAL=0

start() {
    su -p $TOMCAT_USER -c "$CATALINA_HOME/bin/catalina.sh start"
    RETVAL=$?
}

stop() {
    su -p $TOMCAT_USER -c "$CATALINA_HOME/bin/catalina.sh stop 60 -force"
    RETVAL=$?
}

status() {
    if [ ! -z "$CATALINA_PID" ]; then
        if [ -f "$CATALINA_PID" ]; then
            echo "$NAME is running"
            RETVAL=0
            return
        fi
    fi
    echo "$NAME is not running"
    RETVAL=3
}

debug() {
    su -p $TOMCAT_USER -c "$CATALINA_HOME/bin/catalina.sh jpda start"
    RETVAL=$?
}

case "$1" in
  start)
        start
        ;;
  debug)
        debug
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        start
        ;;
  status)
        status
        ;;
  *)
        echo "Usage: $0 {start|debug|stop|restart|status}"
        exit 1
esac

exit $RETVAL
TBLOCK

# Change executable status of Tomcat
chmod +x /etc/init.d/tomcat
chkconfig --add tomcat

echo "---------------------------------------------"
echo "      Apache Solr installation complete      "
echo "---------------------------------------------"


