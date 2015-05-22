#!/usr/bin/env bash

# Script to provision a CentOS 6.5 64-bit web server using Vagrant
# written by James Dugger

# Global Variables.
# Leave this varible as is it will get changed in the VagrantFile.
#base_name="$(< /vagrant/base_name.conf)"
base_name="${1}"
#base_name="$vm_name"
#base_folder="var/www"

# Address for DNS resolution in /etc/hosts file.  default set to loopback.
address="127.0.0.1"

# Update YUM
#-------------------------------------------------------
yum update -y
yum install -y vim lsof autoconf automake

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
if grep -Fxq "${address} ${base_name}" /etc/hosts
  then
    echo "${base_name} is already added to the loopback address."
  else
    cp /etc/hosts /etc/hosts.back
    echo "${address} ${base_name}" >> /etc/hosts
fi

# Set timezone and ntp
sudo cp /usr/share/zoneinfo/America/Phoenix /etc/localtime
sudo ntpdate pool.ntp.org

echo "---------------------------------------------"
echo "           Base system installed             "
echo "---------------------------------------------"
