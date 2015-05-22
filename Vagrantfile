# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

vconfig=YAML::load_file("vagrant_config.yml")

# Set path variables and server name
# current_path = File.expand_path(__FILE__)
base_path = File.expand_path("../../..", __FILE__)
# explode_path = base_path.split(File::SEPARATOR).map {|x| x=="" ? File::SEPARATOR : x}
# vm_name = explode_path.pop

vm_name = vconfig['base']['name']
base_box = vconfig['base']['box']
http_port = vconfig['base']['port']

# type of server:
#   base (default),
#   dbserv  - Mysql database server
#   wbserv  - Apache & PHP webserver
#   dr_base - LAMP with drupal base
#   solr - Apache Solr server.
#   dr_solr - LAMP with drupal base and solr server.
prov_type="dr_solr"

if prov_type=="dbserv"
  memory = vconfig['dbserv']['memory']
elsif prov_type=="wbserv"
  memory = vconfig['wbserv']['memory']
elsif prov_type=="lamp"
  memory = vconfig['lamp']['memory']
elsif prov_type=="dr_base"
  memory = vconfig['dr_base']['memory']
elsif prov_type=="solr"
  memory = vconfig['solr']['memory']
  # Solr defaults to port 8983.  However if another vm with solr is 
  # Using 8983 use a different port.
  host_solr_port=vconfig['solr']['host_solr_port']
elsif prov_type=="dr_solr"
  memory = vconfig['dr_solr']['memory']
  # Solr defaults to port 8983.  However if another vm with solr is 
  # Using 8983 use a different port.
  host_solr_port=vconfig['solr']['host_solr_port']
else 
  memory = vconfig['base']['memory']
end

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
  config.vm.synced_folder "#{base_path}/dev", "/var/www/#{vm_name}"

  # Provision with BASH
  if prov_type=="dbserv"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif prov_type=="wbserv"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif prov_type=="lamp"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-php.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif prov_type=="dr_base"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-dbserv.sh"
    config.vm.provision :shell, :path => "centos65-apache.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-php.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-drupal.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-iptables.sh"
  elsif prov_type=="solr"
    config.vm.provision :shell, :path => "centos65-base.sh", :args => ["#{vm_name}"]
    config.vm.provision :shell, :path => "centos65-solr.sh", :args => ["#{vm_name}"]
  elsif prov_type=="dr_solr"
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
