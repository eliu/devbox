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
declare -A network_facts
# ----------------------------------------------------------------
# Get ipv4 method, the possible value might be auto or manual
# $1 -> Network uuid
# Scope: private
# ----------------------------------------------------------------
network__ipv4_method() {
  nmcli -terse conn show uuid $1 | grep ipv4.method | awk -F '[:/]' '{print $2}'
}

# ----------------------------------------------------------------
# Gather all facts for network info, including
# 1. uuid      -> exported to network_facts[uuid]
# 2. static ip -> exported to network_facts[ip]
# 3. dns list  -> exported to network_facts[dns]
# ----------------------------------------------------------------
network::gather_facts() {
  [[ -n ${network_facts[dns]} ]] || {
    log::info "Gathering facts for networks..."
    for uuid in $(nmcli -get-values UUID conn show --active); do
      [ "auto" = "$(network__ipv4_method $uuid)" ] && network_facts[uuid]=$uuid
    done

    if [ -z ${network_facts[uuid]} ]; then
      log::warn "Failed to locate correct network interface."
      return 1
    fi

    network_facts[dns]=$(nmcli -terse conn show ${network_facts[uuid]} | grep "ipv4.dns:" | cut -d: -f2)
    network_facts[ip]=$(ip -br -f inet addr | grep 192 | awk -F'[ /]+' '{print $3}')
  }
}

# ----------------------------------------------------------------
# Resolve DNS issue in China
# ----------------------------------------------------------------
network::resolve_dns() {
  network::gather_facts
  
  [[ -n ${network_facts[dns]} && -n ${network_facts[uuid]} ]] || {
    log::info "Resolving dns..."
    for nameserver in $(cat /vagrant/etc/nameserver.conf); do
      log::info "Adding nameserver $nameserver..."
      nmcli con mod ${network_facts[uuid]} +ipv4.dns $nameserver
    done

    log::info "Restarting network manager..."
    systemctl restart NetworkManager
  }
}

export NETWORK_FACTS