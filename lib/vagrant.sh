VAGRANT_HOME="/home/vagrant"
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
  [[ "root" = $(whoami) ]] && $@ || sudo bash -c "$@"
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

vg::user_cache() {
  log::info "Making cache for user 'vagrant'. This will take a few seconds..."
  vg::exec "dnf $QUIET_FLAG_Q makecache >$QUIET_STDOUT 2>&1"
}
