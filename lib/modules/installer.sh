#
# Copyright(c) 2020-2023 Liu Hongyu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
source $MODULE_ROOT/version.sh
source $MODULE_ROOT/setup.sh
source $MODULE_ROOT/accelerator.sh

readonly TEMPDIR="$(mktemp -d)"
readonly M2_MAJOR="3"
readonly M2_VERSION="3.9.5"
readonly M2_URL="$ACC_MIRROR_M2/maven-${M2_MAJOR}/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz"
readonly NODE_VERSION="20.9.0"
readonly NODE_FILENAME="node-v${NODE_VERSION}-linux-x64"
readonly NODE_URL="$ACC_MIRROR_NODE/v${NODE_VERSION}/${NODE_FILENAME}.tar.xz"
readonly IS_QUIET=$(log::is_verbose_enabled || printf -- "-q")

# ----------------------------------------------------------------
# Accelerate repo and context setups
# Scope: private
# ----------------------------------------------------------------
installer__init() {
  setup::dns
  setup::hosts
  setup::context "TZ" "export TZ=Asia/Shanghai"
  setup::context "PATH" "export PATH=/usr/local/bin:\$PATH"
  accelerator::repo
}

# ----------------------------------------------------------------
# Install git
# Scope: private
# ----------------------------------------------------------------
installer__git() {
  config::get installer.git.enabled || return 0
  test::cmd git || {
    log::info "Installing git..."
    dnf install $IS_QUIET -y git
  } 
}

# ----------------------------------------------------------------
# Install python3 and pip3
# Scope: private
# ----------------------------------------------------------------
installer__pip3() {
  config::get installer.pip3.enabled || return 0
  test::cmd python3 pip3 || {
    log::info "Installing python3-pip..."
    dnf install $IS_QUIET -y python3-pip
    accelerator::pip
  }
}

# ----------------------------------------------------------------
# Install openjdk
# Scope: private
# ----------------------------------------------------------------
installer__openjdk() {
  config::get installer.openjdk.enabled || return 0
  test::cmd java || {
    log::info "Installing openjdk-8-devel..."
    dnf install $IS_QUIET -y java-1.8.0-openjdk-devel
    setup::context "JAVA_HOME" "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
  }
}

# ----------------------------------------------------------------
# Install and accelerate epel repo
# Scope: private
# ----------------------------------------------------------------
installer__epel() {
  config::get installer.epel.enabled || return 0
  dnf list installed "epel*" > /dev/null 2>&1 || {
    log::info "Setting up epel repo..."
    dnf install $IS_QUIET -y https://mirrors.aliyun.com/epel/epel-release-latest-9.noarch.rpm
    accelerator::epel
  }
}

# ----------------------------------------------------------------
# Install container runtime
# Scope: private
# ----------------------------------------------------------------
installer__container_runtime() {
  config::get installer.container.enabled || return 0
  test::cmd podman || {
    log::info "Installing podman..."
    dnf install $IS_QUIET -y podman

    log::info "Installing podman compose as user vagrant..."
    vg::exec "pip3 $IS_QUIET install podman-compose"
    accelerator::container_registry
  }
}

# ----------------------------------------------------------------
# Install Maven
# Scope: private
# ----------------------------------------------------------------
installer__maven() {
  config::get installer.maven.enabled || return 0
  test::cmd mvn || {
    log::info "Downloading ${M2_URL}"
    curl -sSL ${M2_URL} -o "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
    log::info "Extracting files to /opt..."
    tar zxf "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
    accelerator::maven
    setup::context "MAVEN_HOME" "export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}"
    setup::context "PATH" "export PATH=\$MAVEN_HOME/bin:\$PATH"
  }
}

# ----------------------------------------------------------------
# Install frontend tools
# Scope: private
# ----------------------------------------------------------------
installer__fe() {
  config::get installer.frontend.enabled || return 0
  test::cmd npm || {
    log::info "Installing node and npm..."
    log::info "Downloading ${NODE_URL}"
    curl -sSL ${NODE_URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    setup::context "PATH" "export PATH=/opt/${NODE_FILENAME}/bin:\$PATH"
    accelerator::npm_registry
  }

  test::cmd yarn lerna || {
    log::info "Installing yarn and lerna..."
    npm install -s -g npm
    npm install -s -g yarn
    yarn -s global add lerna
  }
}

# ----------------------------------------------------------------
# Print machine info and flags
# Scope: private
# ----------------------------------------------------------------
installer__wrap_up() {
  network::gather_facts
  log::info "All set! Wrap it up..."
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
$(config::get installer.pip3.enabled && echo "SOFTWARE VERSION|PYTHON3|$(style::green $(version::python3))")
$(config::get installer.pip3.enabled && echo "SOFTWARE VERSION|PIP3|$(style::green $(version::pip3))")
$(config::get installer.container.enabled && echo "SOFTWARE VERSION|PODMAN|$(style::green $(version::podman))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|NODE|$(style::green $(version::common node))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|NPM|$(style::green $(version::common npm))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|YARN|$(style::green $(version::common yarn))")
$(config::get installer.frontend.enabled && echo "SOFTWARE VERSION|LERNA|$(style::green $(version::common lerna))")
EOF
}

# ----------------------------------------------------------------
# Print machine info and flags
# ----------------------------------------------------------------
installer::setup_and_install() {
  log::is_debug_enabled && set -x || true
  installer__init
  installer__git
  installer__pip3
  installer__openjdk
  installer__epel
  installer__maven
  installer__container_runtime
  installer__fe
  installer__wrap_up
  log::is_debug_enabled && set +x || true
}