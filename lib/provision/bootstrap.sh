#!/usr/bin/env bash
#
# Copyright(c) 2020-2023 eliu (eliuhy@163.com)
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
set -e

export MACHINE_IP=$1
export DEBUG=$2

source /vagrant/lib/modules/setup.sh
source /vagrant/lib/modules/basesvc.sh
source /vagrant/lib/modules/installer.sh

DEBUG set -x
log::info "MACHINE IP -> $MACHINE_IP"
log::info "DEBUG ENABLED -> $DEBUG"
setup::hosts
setup::resolve_dns
basesvc::init
installer::base_packages
installer::maven
installer::container_runtime
installer::fe
installer::print_versions
DEBUG set +x