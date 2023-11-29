source /vagrant/devbox.sh
source /vagrant/lib/modules/accelerator.sh

readonly TEMPDIR="$(mktemp -d)"
readonly M2_MAJOR="3"
readonly M2_VERSION="3.9.5"
readonly M2_URL="$M2_MIRROR/maven-${M2_MAJOR}/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz"
readonly NODE_VERSION="20.9.0"
readonly NODE_FILENAME="node-v${NODE_VERSION}-linux-x64"
readonly NODE_URL="$NODE_MIRROR/v${NODE_VERSION}/${NODE_FILENAME}.tar.xz"
readonly IS_QUIET=$(! $DEBUG && printf -- "-q")

# ----------------------------------------------------------------
# Install base packages
# ----------------------------------------------------------------
installer::base_packages() {
  if sys_already_installed java vim git; then
    log::info "Base packages already existed. Skip installation..."
    return 0
  fi
  accelerator::repo
  log::info "Installing base packages..."
  dnf install $IS_QUIET -y java-1.8.0-openjdk-devel git vim
}

installer::container_runtime() {
  if sys_already_installed podman; then
    log::info "Container runtime already existed. Skip installation..."
    return 0
  fi
  log::info "Installing Podman..."
  dnf install $IS_QUIET -y python3-pip podman
  log::info "Installing Podman Compose..."
  su - vagrant <<EOF
pip3 $IS_QUIET install podman-compose -i $PIP3_MIRROR
EOF
  accelerator::container_registry
  setup::context "export TZ=Asia/Shanghai"
  setup::context "export PATH=/usr/local/bin:\$PATH"
  setup::context "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
}

# ----------------------------------------------------------------
# Install Maven
# ----------------------------------------------------------------
installer::maven() {
  if sys_already_installed mvn; then
    log::info "Maven has been previously installed. Skip installation..."
    return 0
  fi
  log::info "Installing Maven ..."
  log::info "Downloading ${M2_URL}"
  curl -sSL ${M2_URL} -o "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
  log::info "Extracting files to /opt ..."
  tar zxf "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
  accelerator::maven
  setup::context "export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}"
  setup::context "export PATH=\$MAVEN_HOME/bin:\$PATH"
}

# ----------------------------------------------------------------
# Install frontend tools
# ----------------------------------------------------------------
installer::fe() {
  if sys_already_installed npm; then
    log::info "NPM has been previously installed. Skip installation..."
  else
    log::info "Installing node and npm..."
    log::info "Downloading ${NODE_URL}"
    curl -sSL ${NODE_URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    setup::context "export PATH=/opt/${NODE_FILENAME}/bin:\$PATH"
    accelerator::npm_registry
  fi

  if sys_already_installed yarn lerna; then
    log::info "Yarn and Lerna have been previously installed. Skip installation..."
  else
    log::info "Installing yarn and lerna..."
    npm install -s -g npm
    npm install -s -g yarn
    yarn -s global add lerna
  fi
}

# ----------------------------------------------------------------
# Verify all versions of installed components
# ----------------------------------------------------------------
installer::print_versions() {
  log::info "VERIFY PACKAGE VERSION..."
  cat << EOF | column -t -N "SOFTWARE,VERSION"
  -------- -------
  $(installed node   && echo "Node    $(color::green $(node -v))")
  $(installed npm    && echo "npm     $(color::green $(npm -v))")
  $(installed yarn   && echo "Yarn    $(color::green $(yarn -v))")
  $(installed lerna  && echo "Lerna   $(color::green $(lerna -v))")
  $(installed java   && echo "OpenJDK $(color::green $(java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}'))")
  $(installed mvn    && echo "Maven   $(color::green $(mvn -version | head -n 1 | awk '{print $3}'))")
  $(installed git    && echo "Git     $(color::green $(git version | awk '{print $3}'))")
  $(installed podman && echo "Podmam  $(color::green $(podman version | grep Version | head -n 1 | awk '{print $2}'))")
EOF
}