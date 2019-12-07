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

hostname = "#{configValues['project']['name']}"

required_plugins = %w( vagrant-hostmanager )
required_plugins.each do |plugin|
  raise "plugin #{plugin} is not installed!" unless Vagrant.has_plugin? plugin
end

Vagrant.configure("2") do |config|

  config.vm.box = "rethinc-oss/baseimage-ubuntu-1804"

  config.vm.hostname = "#{hostname}.localdev"
  config.hostmanager.aliases = ["www.#{hostname}.localdev"]

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
