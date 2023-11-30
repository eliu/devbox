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
# Pring machine info and flags
# ----------------------------------------------------------------
setup::info() {
  cat << EOF | column -t -s "|"
$(log::info "MACHINE OS|->|$(cat /etc/system-release)")
$(log::info "MACHINE IP|->|$MACHINE_IP")
$(log::info "DEBUG ENABLED|->|$DEBUG")
EOF
}

# ----------------------------------------------------------------
# Set up environment variables
# ----------------------------------------------------------------
setup::context() {
  if [[ -n $1 ]]; then
    log::info "Setting up environment..."
    echo "$1" >> /etc/profile.d/devbox.sh
    source /etc/profile > /dev/null
  else
    log::warn "Context details not provided."
  fi
}

# ----------------------------------------------------------------
# Setup hosts
# ----------------------------------------------------------------
setup::hosts() {
  log::info "Setting up machine hosts..."
  if ! cat /etc/hosts | grep dev.$APP_DOMAIN > /dev/null; then
    cat >> /etc/hosts << EOF
$MACHINE_IP dev.$APP_DOMAIN
$MACHINE_IP db.$APP_DOMAIN
$MACHINE_IP redis.$APP_DOMAIN
$MACHINE_IP file.$APP_DOMAIN
EOF
    hostnamectl set-hostname dev.$APP_DOMAIN
  fi
}

# ----------------------------------------------------------------
# Resolve DNS issue
# ----------------------------------------------------------------
setup::resolve_dns() {
  log::info "Find network interface with real internet connection..."
  local network_uuid=
  for uuid in $(nmcli -get-values UUID conn show --active); do
    if [ "auto" = "$(nmcli -terse conn show uuid $uuid | grep ipv4.method | awk -F '[:/]' '{print $2}')" ]; then
    network_uuid=$uuid
    fi
  done

  if [ -z $network_uuid ]; then
    log::warn "Failed to locate correct network interface."
    return 1
  fi

  log::info "Resolving DNS..."
  for nameserver in $(cat /vagrant/etc/nameserver.conf); do
    log::info "Adding nameserver $nameserver..."
    nmcli con mod $network_uuid +ipv4.dns $nameserver
  done

  log::info "Restarting network manager..."
  systemctl restart NetworkManager
}