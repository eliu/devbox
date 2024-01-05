# -*- mode: ruby -*-
# vi: set ft=ruby :

# Change as needed
MACHINE_IP = "192.168.133.100"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/rockylinux-9"
  config.vm.box_check_update = false
  # https://github.com/dotless-de/vagrant-vbguest/issues/351
  config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
  config.vm.network "private_network", ip: "#{MACHINE_IP}"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = "2048"
  end

  # Bootstrap step right after `vagrant up`
  config.vm.provision "shell", keep_color: true, path: "bin/boot.sh"

  # Provision base services using podman compose
  config.vm.provision "base services", type: "shell", 
    run: "never",
    privileged: false,
    keep_color: true,
    path: "bin/svcup.sh"

  # Check if all base services are under normal status
  config.vm.provision "health check", type: "shell", 
    run: "never",
    privileged: false,
    keep_color: true,
    path: "bin/svcps.sh"
end
