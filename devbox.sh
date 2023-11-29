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
source /vagrant/lib/modules/log.sh

export VAGRANT_HOME="/home/vagrant"
export APP_HOME="/devbox"
export APP_DOMAIN="example.com"

# --- common functions definition ---
DEBUG() { $DEBUG && $@ || true
}
sys_already_installed() {
  local exit_code=0
  while [ $# -gt 0 ]; do
    if ! command -v $1 >/dev/null 2>&1; then
      exit_code=1
      break
    fi
    shift
  done
  return $exit_code
}
# Make shorhand alias
shopt -s expand_aliases
alias installed=sys_already_installed
