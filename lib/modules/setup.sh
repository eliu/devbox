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
source /vagrant/lib/modules/version.sh
SETUP_NETWORK_UUID=
SETUP_DNS_LIST=

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
  cat /etc/hosts | grep dev.$APP_DOMAIN > /dev/null || {
    log::info "Setting up machine hosts..."
    cat >> /etc/hosts << EOF
$MACHINE_IP dev.$APP_DOMAIN
$MACHINE_IP db.$APP_DOMAIN
$MACHINE_IP redis.$APP_DOMAIN
$MACHINE_IP file.$APP_DOMAIN
EOF
    hostnamectl set-hostname dev.$APP_DOMAIN
  }
}

setup::network_uuid() {
  for uuid in $(nmcli -get-values UUID conn show --active); do
    if [ "auto" = "$(nmcli -terse conn show uuid $uuid | grep ipv4.method | awk -F '[:/]' '{print $2}')" ]
    then
      SETUP_NETWORK_UUID=$uuid
    fi
  done

  if [ -z $SETUP_NETWORK_UUID ]; then
    log::warn "Failed to locate correct network interface."
    return 1
  fi
}

setup::dns_list() {
  SETUP_DNS_LIST=$(nmcli -terse conn show $SETUP_NETWORK_UUID | grep "ipv4.dns:" | cut -d: -f2)
}

# ----------------------------------------------------------------
# Resolve DNS issue
# ----------------------------------------------------------------
setup::resolve_dns() {
  setup::network_uuid
  setup::dns_list
  
  [[ -n $SETUP_DNS_LIST && -n $SETUP_NETWORK_UUID ]] || {
    log::info "Resolving dns..."
    for nameserver in $(cat /vagrant/etc/nameserver.conf); do
      log::info "Adding nameserver $nameserver..."
      nmcli con mod $SETUP_NETWORK_UUID +ipv4.dns $nameserver
    done

    log::info "Restarting network manager..."
    systemctl restart NetworkManager
  }
}

# ----------------------------------------------------------------
# Print machine info and flags
# ----------------------------------------------------------------
setup::wrap_up() {
  setup::network_uuid
  setup::dns_list
  log::info "All set! Wrap it up..."
  cat << EOF | column -t -s "|" -N CATEGORY,NAME,VALUE
--------|----|-----
PROPERTY|MACHINE_OS  |$(style::green $(version::os))
PROPERTY|MACHINE_IP  |$(style::green $(version::ip))
PROPERTY|USING_DNS |$(style::green $SETUP_DNS_LIST)
--------|----|-----
SOFTWARE|OPENJDK     |$(style::green $(version::java))
SOFTWARE|MAVEN       |$(style::green $(version::maven))
SOFTWARE|GIT         |$(style::green $(version::git))
SOFTWARE|PODMAN      |$(style::green $(version::podman))
SOFTWARE|NODE        |$(style::green $(version::common node))
SOFTWARE|NPM         |$(style::green $(version::common npm))
SOFTWARE|YARN        |$(style::green $(version::common yarn))
SOFTWARE|LERNA       |$(style::green $(version::common lerna))
EOF
}