require logging
declare -gA network_facts
# ----------------------------------------------------------------
# Get uuids of all active connections
# Scope: private
# ----------------------------------------------------------------
network::get_active_uuids() {
  nmcli -get-values UUID conn show --active
}

# ----------------------------------------------------------------
# Get ipv4 method, the possible value might be auto or manual
# $1 -> network uuid
# Scope: private
# ----------------------------------------------------------------
network::get_ipv4_method_of() {
  nmcli -terse conn show uuid $1 \
    | grep ipv4.method \
    | awk -F '[:/]' '{print $2}'
}

# ----------------------------------------------------------------
# Gather network uuid with auto ipv4 method
# Scope: private
# ----------------------------------------------------------------
network::gather_uuid_with_auto_method() {
  for uuid in $(network::get_active_uuids); do
    [[ "auto" = $(network::get_ipv4_method_of $uuid) ]] && {
      network_facts[uuid]=$uuid
      return
    }
  done
  log::fatal "Failed to locate correct network interface."
}

# ----------------------------------------------------------------
# Gather dns list
# ----------------------------------------------------------------
network::gather_dns() {
  network_facts[dns]=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | xargs | tr ' ' ',')
}

# ----------------------------------------------------------------
# Gather static ip address
# Scope: private
# ----------------------------------------------------------------
network::gather_static_ip() {
  network_facts[ip]=$(ip -brief -family inet addr | grep 192 | awk -F'[ /]+' '{print $3}')
}

# ----------------------------------------------------------------
# Gather all facts for network info, including
# 1. uuid      -> exported to network_facts[uuid]
# 2. static ip -> exported to network_facts[ip]
# 3. dns list  -> exported to network_facts[dns]
# ----------------------------------------------------------------
network::gather_facts() {
  log::verbose "Gathering facts for networks...$1"
  if [[ $1 = '--of-all' ]]; then
    network::gather_uuid_with_auto_method
  fi
  network::gather_dns
  network::gather_static_ip

  log::is_verbose && fmt_dict network_facts || true
}

network::dns_available() {
  [[ $(grep nameserver /etc/resolv.conf | wc -l) -ge 2 ]]
}

# ----------------------------------------------------------------
# Resolve DNS issue in China
# ----------------------------------------------------------------
network::resolve_dns() {
  if network::dns_available; then
    return
  fi

  network::gather_facts --of-all
  
  log::info "Resolving dns..."
  for nameserver in $(cat /vagrant/etc/networks/nameserver.conf); do
    log::verbose "Adding nameserver $nameserver..."
    nmcli con mod ${network_facts[uuid]} +ipv4.dns $nameserver
  done

  log::verbose "Restarting network manager..."
  systemctl restart NetworkManager
}

export network_facts
