require logging
require config

git::installer() {
  config::get installer.git.enabled && {
    has_command git || {
      log::info "Installing git..."
      dnf install $QUIET_FLAG_Q -y git >$QUIET_STDOUT
    } 
  } || {
    has_command git && {
      log::info "Uninstalling git..."
      dnf remove $QUIET_FLAG_Q -y git >$QUIET_STDOUT
    } || true
  }
}

git::version() {
  has_command git && git version | awk '{print $3}'
}
