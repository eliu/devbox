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
# ----------------------------------------------------------------
# Execute command as vagrant
# ----------------------------------------------------------------
vg::exec() {
  [[ "root" = $(whoami) ]] && su vagrant -c "$@" || $@
}

# ----------------------------------------------------------------
# Execute command as root. User vagrant can become root via sudo
# ----------------------------------------------------------------
vg::sudo_exec() {
  local context="$MODULE_ROOT/vagrant.sh"
  [[ "root" = $(whoami) ]] && $@ || sudo bash -c ". $context && $@"
}

# ----------------------------------------------------------------
# Change owner to vagrant
# ----------------------------------------------------------------
vg::chown() {
  vg::sudo_exec "chown -R vagrant:vagrant $1"
}

# ----------------------------------------------------------------
# Fix the following error that will cause all running containers stopped unexpectly.
# ERRO[0000] Refreshing container <containerID>: 
# error acquiring lock 0 for container <containerID>: file exists
# ---
# Issue: https://github.com/containers/podman/issues/16784#issuecomment-1711364992
# ----------------------------------------------------------------
vg::enable_linger() {
  vg::sudo_exec "loginctl enable-linger vagrant"
}

# ----------------------------------------------------------------
# Append content to vagrant's context
# ----------------------------------------------------------------
vg::env() {
  vg::exec "echo \"$@\" >> \$HOME/.bashrc"
}

# ----------------------------------------------------------------
# Add vagrant to user group $1
# ----------------------------------------------------------------
vg::add_user_group() {
  vg::sudo_exec "usermod -aG $1 vagrant"
}
