require vagrant
require logging
require config
require setup


openjdk::installer() {
  config::get installer.openjdk.enabled && openjdk::install || openjdk::uninstall
}

openjdk::install() {
  has_command java || {
    log::info "Installing openjdk-8-devel..."
    dnf install $QUIET_FLAG_Q -y java-1.8.0-openjdk-devel >$QUIET_STDOUT
    setup::add_context "JAVA_HOME" "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
  }
}

openjdk::uninstall() {
  has_command java && {
    setup::del_context "JAVA_HOME"
    log::info "Uninstalling openjdk-8-devel..."
    dnf remove $QUIET_FLAG_Q -y java-1.8.0-openjdk-devel >$QUIET_STDOUT
  } || true
}

openjdk::version() {
  has_command java && java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}'
}
