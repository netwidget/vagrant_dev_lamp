# vagrant_dev_lamp
Dependencies:
-Linux/Windows/Mac running 64bit Operating System.
-Ruby Vagrant vagrant-vbguest (vagrant plugin for VirtualBox Guest additions). vagrant base box for CentOS 6.5 64bit VirtualBox

Pre Guest VM installation:
-Install Ruby - if not installed.
-Install Vagrant
-Install vagrant-vbguest plugin
-gem install vagrant-vbguest
-Install Vagrant base box (CentOS 6.5 64bit)
-vagrant box add centos64-x64 http://box.puphpet.com/centos64-x64-vbox43.box
-This will download a pre-built centOS 6.5 x64 base box with VirtualBox 4.3 Guest Additions already installed on it.

To use NFS (on Mac):
previous to Vagrant

Alter sudo privileges to allow the Vagrant application to edit the NFS /etc/export file
```bash
$ visudo
```

Add the following lines to the end of the sudo file:
```bash
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports                   
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart                                    
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports 
%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE 
```

Directory setup.
The recommended directory structure is:

-Locate all varant-based provisioning scripts etc in this file path:
    home/sitedev/[proj_name]/server/vagrant/

-Locate all website code and files in this file path:
    home/sitedev/[proj_name]/dev/docroot/

