# -*- mode: ruby -*-
# vi: set ft=ruby :

# 根据实际情况调整，一般保持默认即可
MACHINE_IP = "192.168.133.100"
DEBUG      = "false"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  config.vm.box_check_update = false
  # https://github.com/dotless-de/vagrant-vbguest/issues/351
  config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
  config.vm.network "private_network", ip: "#{MACHINE_IP}"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = "8192"
  end

  # 执行引导脚本安装基础环境
  config.vm.provision "shell", inline: <<-SHELL
    export DEBUG=#{DEBUG}
    for script in /vagrant/scripts/bootstrap/*.sh; do
      $script #{MACHINE_IP} || exit $?
    done
  SHELL

  # 启动基础服务
  config.vm.provision "base-service", type: "shell", run: "never", privileged: false, inline: <<-SHELL
    /vagrant/scripts/provisioner/install-base-services.sh
  SHELL

  # 检查基础服务是否运行正常
  config.vm.provision "health-check", type: "shell", run: "never", privileged: false, inline: <<-SHELL
    /vagrant/scripts/provisioner/health-check.sh
  SHELL

  # Install npm, yarn and lerna
  config.vm.provision "frontend-tools", type: "shell", run: "never", privileged: true, inline: <<-SHELL
    /vagrant/scripts/provisioner/install-frontend-tools.sh
  SHELL
end
