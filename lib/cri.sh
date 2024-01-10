require logging test vagrant
#===  FUNCTION  ================================================================
#         NAME: podman::accelerate
#  DESCRIPTION: Accelerate registries of podman
# PARAMETER  1: ---
#===============================================================================
podman::accelerate() {
  log::info "Accelerating container registry..."
  mv /etc/containers/registries.conf /etc/containers/registries.conf.bak
  \cp -f /vagrant/etc/containers/registries.conf /etc/containers/registries.conf
}

#===  FUNCTION  ================================================================
#         NAME: podman::install
#  DESCRIPTION: Install podman
# PARAMETER  1: ---
#===============================================================================
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

#===  FUNCTION  ================================================================
#         NAME: podman::remove
#  DESCRIPTION: Uninstall podman
# PARAMETER  1: ---
#===============================================================================
podman::remove() {
  test::cmd podman && {
    log::info "Uninstalling podman-compose..."
    vg::exec "pip3 $QUIET_FLAG_Q uninstall podman-compose" >$QUIET_STDOUT 2>&1
    log::info "Uninstalling podman..."
    dnf remove $QUIET_FLAG_Q -y podman >$QUIET_STDOUT 2>&1
  } || true
}

#===  FUNCTION  ================================================================
#         NAME: podman::version
#  DESCRIPTION: Extract podman version
# PARAMETER  1: ---
#===============================================================================
podman::version() {
  podman version | grep Version | head -n 1 | awk '{print $2}'
}

#===  FUNCTION  ================================================================
#         NAME: docker::accelerate
#  DESCRIPTION: Accelerate registries of docker
# PARAMETER  1: ---
#===============================================================================
docker::accelerate() {
  if [[ -f /etc/docker/daemon.json ]]; then
    mv /etc/docker/daemon.json /etc/docker/daemon.json.bak
  fi
  \cp -f /vagrant/etc/docker/daemon.json /etc/docker/daemon.json
}

#===  FUNCTION  ================================================================
#         NAME: docker::install
#  DESCRIPTION: Install docker
# PARAMETER  1: ---
#===============================================================================
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

#===  FUNCTION  ================================================================
#         NAME: docker::remove
#  DESCRIPTION: Uninstall docker
# PARAMETER  1: ---
#===============================================================================
docker::remove() {
  test::cmd docker && {
    log::info "Uninstalling docker-ce...."
    dnf remove $QUIET_FLAG_Q -y docker-ce >$QUIET_STDOUT 2>&1
  } || true
}

#===  FUNCTION  ================================================================
#         NAME: docker::version
#  DESCRIPTION: Extract docker version
# PARAMETER  1: ---
#===============================================================================
docker::version() {
  expr "$(docker -v)" : 'Docker version \(.*\),.*$'
}

#===  FUNCTION  ================================================================
#         NAME: cri::install
#  DESCRIPTION: Install cri implementation
# PARAMETER  1: ---
#===============================================================================
cri::install() {
  "$CRI_COMMAND::install"
}

#===  FUNCTION  ================================================================
#         NAME: cri::remove
#  DESCRIPTION: Uninstall cri implementation
# PARAMETER  1: ---
#===============================================================================
cri::remove() {
  "$CRI_COMMAND::remove"
}

#===  FUNCTION  ================================================================
#         NAME: cri::cmd
#  DESCRIPTION: Execute the actual cri command: podman or docker
# PARAMETER  1: ---
#===============================================================================
cri::cmd() {
  $CRI_COMMAND $@
}

#===  FUNCTION  ================================================================
#         NAME: cri::compose
#  DESCRIPTION: Return the actual compose provider
# PARAMETER  1: ---
#===============================================================================
cri::compose() {
  cri::is_podman && podman-compose $@
  cri::is_podman || docker compose $@
}

#===  FUNCTION  ================================================================
#         NAME: cri::version
#  DESCRIPTION: Print version of actual cri command
# PARAMETER  1: ---
#===============================================================================
cri::version() {
  "$CRI_COMMAND::version"
}

#===  FUNCTION  ================================================================
#         NAME: cri::is_podman
#  DESCRIPTION: Return true if current cri implementation is podman
# PARAMETER  1: ---
#===============================================================================
cri::is_podman() {
  [[ 'podman' = $(config::get installer.container.runtime) ]]
}

export CRI_COMMAND=$(cri::is_podman && echo "podman" || echo "docker")
