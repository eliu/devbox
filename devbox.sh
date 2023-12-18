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
export VAGRANT_HOME="/home/vagrant"
export APP_HOME="/devbox"
export APP_DOMAIN="example.com"
export MODULE_ROOT="/vagrant/lib/modules"
source $MODULE_ROOT/loggiing.sh
source $MODULE_ROOT/test.sh
source $MODULE_ROOT/basesvc.sh
source $MODULE_ROOT/installer.sh

# --- common functions definition ---
devbox::exec_if_debug() {
  $DEBUG && $@ || true
}

devbox::bootstrap() {
  devbox::exec_if_debug set -x
  setup::hosts
  setup::dns
  installer::base_packages
  installer::epel
  installer::maven
  installer::container_runtime
  basesvc::init
  [[ "fe" = $1 ]] && installer::fe
  setup::wrap_up
  devbox::exec_if_debug set +x
}
