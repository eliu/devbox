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
source /vagrant/lib/modules/vagrant.sh

# ----------------------------------------------------------------
# Initialize workspace for container services
# ----------------------------------------------------------------
basesvc::init() {
  [[ -d $APP_HOME/basesvc ]] || {
    log::info "Deploying base services..."
    mkdir -p "$APP_HOME"
    \cp -r /vagrant/etc/basesvc "$APP_HOME/"
    vg::chown "$APP_HOME"
    vg::enable_linger
  }
}

# ----------------------------------------------------------------
# Start base services
# ----------------------------------------------------------------
basesvc::up() {
  local is_quiet=$(! $DEBUG && printf -- "--quiet-pull")
  cd "$APP_HOME/basesvc"
  test::cmd podman-compose && podman-compose up $is_quiet -d mysql redis minio
}

# ----------------------------------------------------------------
# Print running status of base services
# ----------------------------------------------------------------
basesvc::ps() {
  cd "$APP_HOME/basesvc"
  test::cmd podman-compose && podman-compose ps
}