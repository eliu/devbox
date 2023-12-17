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
source $MODULE_ROOT/version.sh
source $MODULE_ROOT/network.sh
# ----------------------------------------------------------------
# Set up environment variables
# PARAMETERS
# $1 -> synopsis
# $2 -> export statement
# ----------------------------------------------------------------
setup::context() {
  if [[ -n $2 ]]; then
    log::info "Setting up environment for $1..."
    echo "$2" >> /etc/profile.d/devbox.sh
    source /etc/profile > /dev/null
  else
    log::fata "Context details not provided."
  fi
}

# ----------------------------------------------------------------
# Setup hosts
# ----------------------------------------------------------------
setup::hosts() {
  network::gather_facts
  cat /etc/hosts | grep dev.$APP_DOMAIN > /dev/null || {
    log::info "Setting up machine hosts..."
    cat >> /etc/hosts << EOF
${network_facts[ip]} dev.$APP_DOMAIN
${network_facts[ip]} db.$APP_DOMAIN
${network_facts[ip]} redis.$APP_DOMAIN
${network_facts[ip]} file.$APP_DOMAIN
EOF
  }
}

# ----------------------------------------------------------------
# Call network module to resolve dns
# ----------------------------------------------------------------
setup::dns() {
  network::resolve_dns
}

# ----------------------------------------------------------------
# Print machine info and flags
# ----------------------------------------------------------------
setup::wrap_up() {
  network::gather_facts
  log::info "All set! Wrap it up..."
  cat << EOF | column -t -s "|" -N CATEGORY,NAME,VALUE
----------------|----|-----
PROPERTY|MACHINE_OS  |$(style::green $(version::os))
PROPERTY|MACHINE_IP  |$(style::green ${network_facts[ip]})
PROPERTY|USING_DNS   |$(style::green ${network_facts[dns]})
----------------|----|-----
SOFTWARE VERSION|EPEL   |$(style::green $(version::epel))
SOFTWARE VERSION|OPENJDK|$(style::green $(version::java))
SOFTWARE VERSION|MAVEN  |$(style::green $(version::maven))
SOFTWARE VERSION|GIT    |$(style::green $(version::git))
SOFTWARE VERSION|PODMAN |$(style::green $(version::podman))
SOFTWARE VERSION|NODE   |$(style::green $(version::common node))
SOFTWARE VERSION|NPM    |$(style::green $(version::common npm))
SOFTWARE VERSION|YARN   |$(style::green $(version::common yarn))
SOFTWARE VERSION|LERNA  |$(style::green $(version::common lerna))
EOF
}