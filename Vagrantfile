# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Copyright(c) 2020-2023 Liu Hongyu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Change as needed
MACHINE_IP = "192.168.133.100"
DEBUG      = "false"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/rockylinux-9"
  config.vm.box_check_update = false
  # https://github.com/dotless-de/vagrant-vbguest/issues/351
  config.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")
  config.vm.network "private_network", ip: "#{MACHINE_IP}"
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = "4096"
  end

  # Bootstrap step right after `vagrant up`
  config.vm.provision "shell" do |s|
    s.path       = "lib/provision/bootstrap.sh"
    s.args       = ["#{MACHINE_IP}", "#{DEBUG}"]
    s.keep_color = true
  end

  # Provision base services using podman compose
  config.vm.provision "base services", type: "shell", run: "never" do |s|
    s.privileged = false
    s.path       = "lib/provision/svcup.sh"
    s.args       = ["#{MACHINE_IP}", "#{DEBUG}"]
    s.keep_color = true
  end

  # Check if all base services are under normal status
  config.vm.provision "health check", type: "shell", run: "never", privileged: false,
    keep_color: true,
    path: "lib/provision/health.sh"

  # Install npm, yarn and lerna
  config.vm.provision "frontend tools", type: "shell", run: "never", privileged: true,
    keep_color: true,
    path: "lib/provision/fetools.sh"
end
