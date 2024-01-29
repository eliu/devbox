require logging config version setup accelerator cri vagrant

readonly TEMPDIR="$(mktemp -d)"
readonly M2_MAJOR="3"
readonly M2_VERSION="3.9.5"
readonly M2_URL="$ACC_MIRROR_M2/maven-${M2_MAJOR}/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz"
readonly NODE_VERSION="20.9.0"
readonly NODE_FILENAME="node-v${NODE_VERSION}-linux-x64"
readonly NODE_URL="$ACC_MIRROR_NODE/v${NODE_VERSION}/${NODE_FILENAME}.tar.xz"

# ----------------------------------------------------------------
# Pre-process before installation
# Scope: private
# ----------------------------------------------------------------
installer::preprocess() {
  setup::dns
  setup::hosts
  setup::add_context "TZ" "export TZ=Asia/Shanghai"
  setup::add_context "PATH" "export PATH=/usr/local/bin:\$PATH"
  accelerator::repo
  cri::config_repo
  accelerator::system_cache
}

# ----------------------------------------------------------------
# Post-process after installation
# Scope: private
# ----------------------------------------------------------------
installer::postprocess() {
  accelerator::system_cache
  accelerator::user_cache
}

# ----------------------------------------------------------------
# Install and accelerate epel repo
# Scope: private
# ----------------------------------------------------------------
installer::epel() {
  config::get installer.epel.enabled && {
    dnf list installed "epel*" > /dev/null 2>&1 || {
      log::info "Installing epel-release..."
      dnf install $QUIET_FLAG_Q -y \
        https://mirrors.aliyun.com/epel/epel-release-latest-9.noarch.rpm >$QUIET_STDOUT
      accelerator::epel
    }
  } || {
    dnf list installed "epel*" > /dev/null 2>&1 && {
      log::info "Uninstalling epel-release..."
      dnf remove $QUIET_FLAG_Q -y epel-release >$QUIET_STDOUT 2>&1
    } || true
  }
}

# ----------------------------------------------------------------
# Install git
# Scope: private
# ----------------------------------------------------------------
installer::git() {
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

# ----------------------------------------------------------------
# Install pip3
# We make pip3 installed by default since python3 is available.
# Scope: private
# ----------------------------------------------------------------
installer::pip3() {
  has_command pip3 || {
    log::info "Installing python3-pip..."
    dnf install $QUIET_FLAG_Q -y python3-pip >$QUIET_STDOUT
    accelerator::pip
  }
}

# ----------------------------------------------------------------
# Install container runtime
# Scope: private
# ----------------------------------------------------------------
installer::container_runtime() {
  config::get installer.container.enabled && cri::install || cri::remove
}

# ----------------------------------------------------------------
# Install openjdk
# Scope: private
# ----------------------------------------------------------------
installer::openjdk() {
  config::get installer.openjdk.enabled && {
    has_command java || {
      log::info "Installing openjdk-8-devel..."
      dnf install $QUIET_FLAG_Q -y java-1.8.0-openjdk-devel >$QUIET_STDOUT
      setup::add_context "JAVA_HOME" "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
    }
  } || {
    has_command java && {
      setup::del_context "JAVA_HOME"
      log::info "Uninstalling openjdk-8-devel..."
      dnf remove $QUIET_FLAG_Q -y java-1.8.0-openjdk-devel >$QUIET_STDOUT
    } || true
  }
}

# ----------------------------------------------------------------
# Install Maven
# Scope: private
# ----------------------------------------------------------------
installer::maven() {
  config::get installer.maven.enabled && {
    # check dependencies
    has_command mvn || {
      has_command java || log::fatal "You must install java platform first!"
      log::info "Installing maven..."
      log::verbose "Downloading ${M2_URL}"
      curl -sSL ${M2_URL} -o "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
      log::verbose "Extracting files to /opt..."
      tar zxf "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
      accelerator::maven
      setup::add_context "MAVEN_HOME" "export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}"
      setup::add_context "PATH" "export PATH=\$MAVEN_HOME/bin:\$PATH"
    }
  } || {
    has_command mvn && {
      setup::del_context "MAVEN_HOME"
      log::info "Uninstalling maven..."
      rm -fr /opt/apache-maven*
    } || true
  }
}

# ----------------------------------------------------------------
# Install frontend tools
# Scope: private
# ----------------------------------------------------------------
installer::fe() {
  config::get installer.frontend.enabled && {
    has_command npm || {
      log::info "Installing node and npm..."
      log::verbose "Downloading ${NODE_URL}"
      curl -sSL ${NODE_URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
      log::verbose "Extracting files to /opt..."
      tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
      setup::add_context "PATH" "export PATH=/opt/${NODE_FILENAME}/bin:\$PATH"
      accelerator::npm_registry
    }

    has_command yarn lerna || {
      log::info "Installing yarn and lerna..."
      npm install $QUIET_FLAG_S -g npm >$QUIET_STDOUT || true
      npm install $QUIET_FLAG_S -g yarn >$QUIET_STDOUT || true
      yarn $QUIET_FLAG_S global add lerna >$QUIET_STDOUT || true
    }
  } || {
    has_command yarn lerna && {
      log::info "Uninstalling yarn and lerna..."
      yarn $QUIET_FLAG_S global remove lerna >$QUIET_STDOUT || true
      npm uninstall $QUIET_FLAG_S -g yarn >$QUIET_STDOUT || true
      npm uninstall $QUIET_FLAG_S -g npm >$QUIET_STDOUT || true
      setup::del_context "node"
      rm -fr /opt/node-*
    } || true
  }
}

# ----------------------------------------------------------------
# Print machine info and flags
# Scope: private
# ----------------------------------------------------------------
installer::wrap_up() {
  network::gather_facts
  log::verbose "Installation complete! Wrap it up..."
  cat << EOF | column -t -s "|" -N CATEGORY,NAME,VALUE
----------------|----|-----
PROPERTY|MACHINE_OS  |$(style::green $(version::os))
PROPERTY|MACHINE_IP  |$(style::green ${network_facts[ip]})
PROPERTY|USING_DNS   |$(style::green ${network_facts[dns]})
----------------|----|-----
$(config::get installer.git.enabled && echo "SOFTWARE VERSION|GIT|$(style::green $(version::git))")
$(config::get installer.epel.enabled && echo "SOFTWARE VERSION|EPEL|$(style::green $(version::epel))")
$(config::get installer.openjdk.enabled && echo "SOFTWARE VERSION|OPENJDK|$(style::green $(version::java))")
$(config::get installer.maven.enabled && echo "SOFTWARE VERSION|MAVEN|$(style::green $(version::maven))")
SOFTWARE VERSION|PIP3|$(style::green $(version::pip3))
$(config::get installer.container.enabled && echo "SOFTWARE VERSION|$CRI_COMMAND|$(style::green $(cri::version))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|NODE|$(style::green $(version::of node))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|NPM|$(style::green $(version::of npm))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|YARN|$(style::green $(version::of yarn))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|LERNA|$(style::green $(version::of lerna))")
EOF
}

# ----------------------------------------------------------------
# Print machine info and flags
# ----------------------------------------------------------------
installer::main() {
  log::is_debug_enabled && set -x || true
  installer::preprocess
  installer::pip3
  installer::container_runtime
  installer::git
  installer::openjdk
  installer::maven
  installer::fe
  installer::epel
  installer::postprocess
  installer::wrap_up
  log::is_debug_enabled && set +x || true
}
