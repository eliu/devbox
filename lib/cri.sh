podman::accelerate() {
  log::info "Accelerating container registry..."
  mv /etc/containers/registries.conf /etc/containers/registries.conf.bak
  \cp -f /vagrant/etc/containers/registries.conf /etc/containers/registries.conf
}

podman::install() {
  test::cmd podman || {
    test::cmd python3 pip3 || log::fatal "You must enable python3-pip first."
    log::info "Installing podman..."
    dnf install $QUIET_FLAG_Q -y podman >$QUIET_STDOUT 2>&1

    log::info "Installing podman compose as user vagrant..."
    vg::exec "pip3 $QUIET_FLAG_Q install podman-compose" >$QUIET_STDOUT 2>&1
    podman::accelerate
  }
}
    
podman::remove() {
  test::cmd podman && {
    log::info "Uninstalling podman-compose..."
    vg::exec "pip3 $QUIET_FLAG_Q uninstall podman-compose" >$QUIET_STDOUT 2>&1
    log::info "Uninstalling podman..."
    dnf remove $QUIET_FLAG_Q -y podman >$QUIET_STDOUT 2>&1
  } || true
}

docker::accelerate() {
  if [[ -f /etc/docker/daemon.json ]]; then
    mv /etc/docker/daemon.json /etc/docker/daemon.json.bak
  fi
  \cp -f /vagrant/etc/docker/daemon.json /etc/docker/daemon.json
}

docker::install() {
  test::cmd docker || {
    log::info "Installing docker-ce..."
    log::verbose "Configuring repo..."
    dnf config-manager \
      --add-repo=https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo \
      >$QUIET_STDOUT 2>&1
    log::verbose "Performing installation..."
    dnf install $QUIET_FLAG_Q -y docker-ce >$QUIET_STDOUT 2>&1
    log::verbose "Accelerating registry..."
    docker::accelerate
    log::verbose "Starting service..."
    systemctl start docker >$QUIET_STDOUT 2>&1
    log::verbose "Making docker service auto start..."
    systemctl enable docker >$QUIET_STDOUT 2>&1
    log::verbose "Add vagrant user to docker group..."
    vg::add_user_group docker
  }
}

docker::remove() {
  test::cmd docker && {
    log::info "Uninstalling docker-ce...."
    dnf remove $QUIET_FLAG_Q -y docker-ce >$QUIET_STDOUT 2>&1
  } || true
}

cri::install() {
  cri::is_podman && podman::install || docker::install
}

cri::remove() {
  cri::is_podman && podman::remove || docker::remove
}

cri::cmd() {
  cri::is_podman && podman $@ || docker $@
}

cri::compose() {
  cri::is_podman && podman-compose $@ || docker compose $@
}

cri::version() {
  cri::is_podman \
    && test::cmd podman && podman version | grep Version | head -n 1 | awk '{print $2}' \
    || test::cmd docker && docker -v 
}

cri::is_podman() {
  [[ 'podman' = $(config::get installer.container.runtime) ]]
}

export CRI_COMMAND=$(cri::is_podman && echo "podman" || echo "docker")
