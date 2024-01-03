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
source $MODULE_ROOT/vagrant.sh
source $MODULE_ROOT/cri.sh
quiet_pull=$(log::is_verbose_enabled || printf -- "--quiet-pull")
# ----------------------------------------------------------------
# Initialize workspace for container services
# ----------------------------------------------------------------
basesvc::init() {
  test::cmd $CRI_COMMAND || log::fatal "Container runtime '$CRI_COMMAND' not installed or invalid."

  [[ -d $APP_HOME/basesvc ]] || {
    log::info "Deploying base services..."
    sudo mkdir -p "$APP_HOME"
    sudo \cp -r /vagrant/etc/basesvc "$APP_HOME/"
    vg::chown "$APP_HOME"
    vg::enable_linger
  }
}

# ----------------------------------------------------------------
# Start base services
# ----------------------------------------------------------------
basesvc::up() {
  cd "$APP_HOME/basesvc"
  cri::compose up $quiet_pull -d mysql redis minio >$QUIET_STDOUT 2>&1
}

# ----------------------------------------------------------------
# Print running status of base services
# ----------------------------------------------------------------
basesvc::ps() {
  cd "$APP_HOME/basesvc"
  cri::compose ps
}