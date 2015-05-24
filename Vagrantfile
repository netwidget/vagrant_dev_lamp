# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
# Load configuration file.
vconfig = YAML::load_file("config.yml")

# Set path variables and server name
# current_path = File.expand_path(__FILE__)
base_path = File.expand_path("../../..", __FILE__)
# explode_path = base_path.split(File::SEPARATOR).map {|x| x=="" ? File::SEPARATOR : x}
# vm_name = explode_path.pop

# Put results of vagrant_config.yml into variables.
v_nfs       = vconfig['nfs']
vm_name     = vconfig['hostname']
base_box    = vconfig['box']
http_port   = vconfig['port']
server_type = vconfig['type']
memory      = vconfig["#{server_type}"]['memory']

if server_type == 'solr'
  host_solr_port = vconfig["#{server_type}"]['host_solr_port']
elsif server_type == 'drsolr'
  host_solr_port = vconfig["#{server_type}"]['host_solr_port']
else
end

# Begin Vagrant 
Vagrant.configure("2") do |config|
  config.vm.define :"#{vm_name}" do |centos_config|
    centos_config.vm.box = "#{base_box}"
    #centos_config.vm.box = "centos64_vboxguest438"
    # If the box has not been added to the local .vagrant.d/boxes uncomment below.
    #centos_config.vm.box_url = "http://box.puphpet.com/centos64-x64-vbox43.box"
  end

  config.vm.provider "virtualbox" do |v|
    v.name = "#{vm_name}" # Change to VM name.
    v.memory = "#{memory}"
  end

  # config.vm.network "private_network", ip: "192.168.33.11"
  # Configure VM to run under VM as NAT with forwarded ports.
  config.vm.network :forwarded_port, guest: 80, host: "#{http_port}", auto_correct: true
 
  # Configure shared folder source and target for host and virtual machine files shares
  # This Vagrantfile defaults to using VirtualBox GuestAddtions, NFS is off.
  # To use NFS as the filesystem protocol Vagrant must have root access to /etc/export.
  # See Vagrant documentation for configuring root access.
  # To configure synced shared folders using NFS uncomment the following line:
  # v_nfs=vconfig['base']['nfs']
  if v_nfs == 'true'
    config.vm.synced_folder "#{base_path}/dev", "/var/www/#{vm_name}", type: "nfs" 
  else 
    config.vm.synced_folder "#{base_path}/dev", "/var/www/#{vm_name}"
  end

  # Provision with BASH
  if server_type =="dbserv"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif server_type =="wbserv"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif server_type =="lamp"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-php.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif server_type =="drbase"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh"
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-php.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-drupal.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif server_type =="solr"
    config.vm.network :forwarded_port, guest: 8983, host: "#{host_solr_port}"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-solr.sh", :args => ["#{vm_name}" "#{host_solr_port}"]
  elsif server_type =="drsolr"
    config.vm.network :forwarded_port, guest: 8983, host: "#{host_solr_port}"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh"
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-php.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-drupal.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-solr.sh", :args => ["#{vm_name}" "#{host_solr_port}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  else
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
  end
end
