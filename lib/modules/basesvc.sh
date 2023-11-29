source /vagrant/devbox.sh
source /vagrant/lib/modules/vagrant.sh

# ----------------------------------------------------------------
# Initialize workspace for container services
# ----------------------------------------------------------------
basesvc::init() {
  log::info "Deploying base services ..."
  mkdir -p "$APP_HOME"
  \cp -r /vagrant/etc/basesvc "$APP_HOME/"
  vagrant::chown "$APP_HOME"
  vagrant::enable_linger
}

basesvc::up() {
  local is_quiet=$(! $DEBUG && printf -- "--quiet-pull")
  cd "$APP_HOME/basesvc"
  sys_already_installed podman-compose && podman-compose up $is_quiet -d mysql redis minio
}

basesvc::ps() {
  cd "$APP_HOME/basesvc"
  sys_already_installed podman-compose && podman-compose ps
}