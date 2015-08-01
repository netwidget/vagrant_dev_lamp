# vagrant_dev_lamp
### Dependencies
- Linux/Windows/Mac running 64bit Operating System.
- Ruby Vagrant vagrant-vbguest (vagrant plugin for VirtualBox Guest additions). vagrant base box for CentOS 6.5 64bit VirtualBox

### Pre Guest VM installation
1. Install Ruby - if not installed.
2. Install Vagrant
3. Install vagrant-vbguest plugin
```bash
$ gem install vagrant-vbguest

### Directory setup.
The recommended directory structure is:
I place the git repo for the server build in a separate subfolder under the projcet name so that the web applicaiton can be versioned separately.  But is in the same project directory so that I can backup the whole project at once as needed.  

* Locate all varant-based provisioning scripts etc in this file path:
```bash
home/sitedev/[proj_name]/server/vagrant/
```
To accomplish this:
1. Make the directory structure up to:
```bash
$ mkdir -P home/sitedev/[proj_name]/server
# If you have a existing git repo for the app then clone it adding docroot at the end
$ mkdir -P home/sitedev/[proj_name]/dev
# OR if this is a new project and you plan on running git init on it
$ mkdir -P home/sitedev/[proj_name]/dev/docroot
```
2. Clone the repo with the following command:
```bash
git clone https://github.com/netwidget/vagrant_dev_lamp.git vagrant
```
* Locate all website code and files in this file path:
```bash
home/sitedev/[proj_name]/dev/docroot/
```

### Make a config.yml file
Once the repo has been cloned go into the vagrant directory and open the Vagrantfile to make the followin edits:
1. After cloning the repo copy the default.config.yml file to config.yml
2. Open the newly created config.yml file and make any changes based in the comments/documentation in the YAML file.

### Changes to Vagrantfile
1. Uncomment the following line in the Vagrantfile:
      #centos_config.vm.box_url = "http://box.puphpet.com/centos64-x64-vbox43.box"
      
### To use NFS
To use NFS for file sharing with the host system (In config.yml file "nfs: true") Changes will need to be made you host system ensure that NFS is installed and that Vagrant has sudo privileges to build, configure, run, and access the share.

(on Linux):
Refer to Linux distro of hostname for installation and configuration of nfs-server and nfs-common for Vagrant.

(on Mac):
1. Prior to staring Vagrant,  alter sudo privileges to allow the Vagrant application to edit the NFS /etc/export file
```bash
$ visudo
```
2. Add the following lines to the end of the sudo file:
```bash
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports                   
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart                                    
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports 
%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE 
```
### Startup the VM
1. Open a terminal
2. Change directories to the vagrant/ directory.
3. Start Vagrant:
```bash
$ vagrant up
```
If all is configured correctly Vagrant will start VirtualBox in the background. The first time it will download the preprepared base CentOS 6 box from box.pupphet.com and then move to the provisioning scripts once the base box is setup.  This first time will take upwards of 20 to 40 minutes to complete.  Once provisioned, subsquent times the server will be up in seconds.

Commands: (These commands must all be run from within the vagrant subfolder)
vagrant up --> Privision a new box or to start an existing build.
vagrant halt --> will shutdown the VM.
vagrant destroy --> will erase all files and remove the bo from VBox list (VirtualBox files, not the provisioning files in the vagrant folder).

