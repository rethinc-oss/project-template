# -*- mode: ruby -*-
# vi: set ft=ruby :

# Include dependencies
dir = File.dirname(File.expand_path(__FILE__))

require 'yaml'
require "#{dir}/.devsupport/vagrant/deep_merge.rb"
require "#{dir}/.devsupport/vagrant/to_bool.rb"
require "#{dir}/.devsupport/vagrant/read_ip_address.rb"

# Load project definition
configValues = YAML.load_file("#{dir}/project.yaml")

hostname = "#{configValues['project']['name']}.localdev"

required_plugins = %w( vagrant-hostmanager )
required_plugins.each do |plugin|
  raise "plugin #{plugin} is not installed!" unless Vagrant.has_plugin? plugin
end

$msg = <<MSG
-----------------------------------------------------------------------
Local Development Environment: #{configValues['project']['type']}

The local development website is viewable at:

    https://#{hostname}/

Database:
---------

A MYSQL database was created and is reachable via:

    Hostname: #{hostname} (or localhost)
    Database: #{hostname}
    Username: #{hostname}
    Password: #{hostname}

SMTP Mailseerver:
-----------------

A local SMTP Mailservice is running inside of the virtual machine.
You can send mal via localhost on port 1025. The mails are not
actually send but are viewable locally under:

    http://#{hostname}:10000/

AWS-S3
------

A local AWS-S3 compatible object storage is available inside of the
virtual machine. A bucket with the name #{hostname}
was automatically created. A web-frontend is available at:

    http://#{hostname}:10001/

-----------------------------------------------------------------------
MSG

Vagrant.configure("2") do |config|

  config.vm.box = "rethinc-oss/baseimage-ubuntu"
  config.vm.box_version = ">= 2004.01, <= 2004.99"
  config.vm.post_up_message = $msg
  
  config.vm.hostname = "#{hostname}"
  config.hostmanager.aliases = ["www.#{hostname}"]
  
  config.vm.network "private_network", type: "dhcp"

  # Enable hostmanager plugin to manage /etc/hosts on local computer and virtual guest(s)
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    read_ip_address(vm)
  end  

  config.vm.provision "shell", path: ".devsupport/provision-librarian-puppet.sh", keep_color: true

  config.vm.provision :puppet do |puppet|
    puppet.environment_path  = ".devsupport/puppet/environments/"
    puppet.environment       = "localdev"
    puppet.hiera_config_path = ".devsupport/puppet/hiera-global.yaml"
#    puppet.options           = ['--verbose']
  end

  config.vm.synced_folder ".", "/vagrant"
end
