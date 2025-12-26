# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "bento/rockylinux-9"
  config.vm.box_check_update = false
  # https://github.com/dotless-de/vagrant-vbguest/issues/351
  config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
  config.vm.network "private_network", ip: "192.168.133.100"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = 2048
  end

  # Bootstrap step right after `vagrant up`
  config.vm.provision "shell", keep_color: true, inline: <<-SHELL
    #!/usr/bin/env bash
    set -euo pipefail
    source /vagrant/include/devbox.env
    require installer
    installer::main
  SHELL

  # Load provisioners dynamically
  Dir.glob("provisioners/*/").each do |provisioner_path|
    begin
      require_relative File.join(provisioner_path, "provision.rb")
      module_path = provisioner_path
        .chomp(File::SEPARATOR) # provisionsers/your_pro/ -> provisionsers/your_pro
        .split(File::SEPARATOR) # provisionsers/your_pro -> ["provisioners", "your_pro"]
        .drop(1) # ["provisioners", "your_pro"] -> ["your_pro"]
        .map { |part| part.split("_").map(&:capitalize).join } # ["your_pro"] -> ["YourPro"]
        .join("::")
      # Get the module and call its provision method
      provisioner_module = Object.const_get(module_path)

      provisioner_name = provisioner_module.instance_variable_get(:@name) || module_path
      provisioner_enabled = provisioner_module.instance_variable_get(:@enabled)

      if provisioner_enabled != nil && provisioner_enabled
          provisioner_module.provision(config)
          puts "Loaded provisioner \"#{provisioner_name}\""
      end
    rescue LoadError => e
      puts "Failed to load provisioner #{provisioner_path}: #{e.message}"
    end
  end
end
