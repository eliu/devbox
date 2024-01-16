require logging
declare -gA network_facts
# ----------------------------------------------------------------
# Get uuids of all active connections
# Scope: private
# ----------------------------------------------------------------
network__get_active_uuids() {
  nmcli -get-values UUID conn show --active
}

# ----------------------------------------------------------------
# Get ipv4 method, the possible value might be auto or manual
# $1 -> network uuid
# Scope: private
# ----------------------------------------------------------------
network__get_ipv4_method_of() {
  nmcli -terse conn show uuid $1 \
    | grep ipv4.method \
    | awk -F '[:/]' '{print $2}'
}

# ----------------------------------------------------------------
# Gather network uuid with auto ipv4 method
# Scope: private
# ----------------------------------------------------------------
network__gather_uuid_with_auto_method() {
  for uuid in $(network__get_active_uuids); do
    [[ "auto" = $(network__get_ipv4_method_of $uuid) ]] && {
      network_facts[uuid]=$uuid
      return
    }
  done
  log::fatal "Failed to locate correct network interface."
}

# ----------------------------------------------------------------
# Gather dns list of specified network
# $1 -> network uuid
# Scope: private
# ----------------------------------------------------------------
network__gather_dns_of() {
  network_facts[dns]=$(nmcli -terse conn show $1 | grep "ipv4.dns:" | cut -d: -f2)
}

# ----------------------------------------------------------------
# Gather static ip address
# Scope: private
# ----------------------------------------------------------------
network__gather_static_ip() {
  network_facts[ip]=$(ip -br -f inet addr | grep 192 | awk -F'[ /]+' '{print $3}')
}

# ----------------------------------------------------------------
# Check if any of the facts is absent
# Scope: private
# ----------------------------------------------------------------
network__facts_absent() {
  [[ -z ${network_facts[uuid]} ]] || \
  [[ -z ${network_facts[dns]}  ]] || \
  [[ -z ${network_facts[ip]}   ]]
}

# ----------------------------------------------------------------
# Gather all facts for network info, including
# 1. uuid      -> exported to network_facts[uuid]
# 2. static ip -> exported to network_facts[ip]
# 3. dns list  -> exported to network_facts[dns]
# ----------------------------------------------------------------
network::gather_facts() {
  if network__facts_absent; then
    log::verbose "Gathering facts for networks..."
    [[ -n ${network_facts[uuid]} ]] || network__gather_uuid_with_auto_method
    [[ -n ${network_facts[dns]}  ]] || network__gather_dns_of ${network_facts[uuid]}
    [[ -n ${network_facts[ip]}   ]] || network__gather_static_ip

    log::is_verbose_enabled && format_hashtable network_facts || true
  fi
}

# ----------------------------------------------------------------
# Resolve DNS issue in China
# ----------------------------------------------------------------
network::resolve_dns() {
  network::gather_facts
  
  [[ -n ${network_facts[dns]} && -n ${network_facts[uuid]} ]] || {
    log::info "Resolving dns..."
    for nameserver in $(cat /vagrant/etc/networks/nameserver.conf); do
      log::verbose "Adding nameserver $nameserver..."
      nmcli con mod ${network_facts[uuid]} +ipv4.dns $nameserver
    done

    log::verbose "Restarting network manager..."
    systemctl restart NetworkManager
  }
}

export network_facts
