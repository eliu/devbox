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
  local host_name=$(config::get setup.host.name)
  config::get setup.host.enabled && {
    cat /etc/hosts | grep $host_name > /dev/null || {
      log::info "Setting up guest hosts..."
      network::gather_facts
      cat >> /etc/hosts << EOF
${network_facts[ip]} dev.$host_name
${network_facts[ip]} db.$host_name
${network_facts[ip]} redis.$host_name
${network_facts[ip]} file.$host_name
EOF
    }
  } || {
    cat /etc/hosts | grep $host_name > /dev/null && {
      log::info "Undoing guest hosts..."
      sed -i "/$host_name/d" /etc/hosts
    } || true
  }
}

# ----------------------------------------------------------------
# Call network module to resolve dns
# ----------------------------------------------------------------
setup::dns() {
  network::resolve_dns
}