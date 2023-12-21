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
source $MODULE_ROOT/network.sh
env_file="/etc/profile.d/devbox.sh"
# ----------------------------------------------------------------
# Set up environment variables
# PARAMETERS
# $1 -> synopsis
# $2 -> export statement
# ----------------------------------------------------------------
setup::add_context() {
  if [[ -n $2 ]]; then
    grep "$2" $env_file > /dev/null 2>&1 || {
      log::verbose "Setting up environment for $1..."
      echo "$2" >> $env_file
      source /etc/profile > /dev/null
    }
  else
    log::fatal "Context details not provided."
  fi
}

# ----------------------------------------------------------------
# Remove environment context
# PARAMETERS
# $1 -> keyword
# ----------------------------------------------------------------
setup::del_context() {
  log::verbose "Deleting environment for keyword $1..."
  sed -i -e "/$1/d" $env_file
  source /etc/profile > /dev/null
}

# ----------------------------------------------------------------
# Setup hosts
# ----------------------------------------------------------------
setup::hosts() {
  config::get setup.hosts.enabled && {
    cat /etc/hosts | grep $APP_DOMAIN > /dev/null || {
      log::info "Setting up guest hosts..."
      network::gather_facts
      cat >> /etc/hosts << EOF
${network_facts[ip]} dev.$APP_DOMAIN
${network_facts[ip]} db.$APP_DOMAIN
${network_facts[ip]} redis.$APP_DOMAIN
${network_facts[ip]} file.$APP_DOMAIN
EOF
    }
  } || {
    cat /etc/hosts | grep $APP_DOMAIN > /dev/null && {
      log::info "Undoing guest hosts..."
      sed -i "/$APP_DOMAIN/d" /etc/hosts
    } || true
  }
}

# ----------------------------------------------------------------
# Call network module to resolve dns
# ----------------------------------------------------------------
setup::dns() {
  network::resolve_dns
}