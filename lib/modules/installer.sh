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
readonly IS_QUIET=$(! $DEBUG && printf -- "-q")

# ----------------------------------------------------------------
# Install base packages
# Scope: private
# ----------------------------------------------------------------
installer__base_packages() {
  test::cmd java vim git pip3 || {
    accelerator::repo
    log::info "Installing base packages that may take some time..."
    dnf install $IS_QUIET -y java-1.8.0-openjdk-devel git vim python3-pip
    accelerator::pip
    
    setup::context "TZ" "export TZ=Asia/Shanghai"
    setup::context "PATH" "export PATH=/usr/local/bin:\$PATH"
    setup::context "JAVA_HOME" "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
  }
}

# ----------------------------------------------------------------
# Install and accelerate epel repo
# Scope: private
# ----------------------------------------------------------------
installer__epel() {
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
SOFTWARE VERSION|EPEL   |$(style::green $(version::epel))
SOFTWARE VERSION|OPENJDK|$(style::green $(version::java))
SOFTWARE VERSION|MAVEN  |$(style::green $(version::maven))
SOFTWARE VERSION|GIT    |$(style::green $(version::git))
SOFTWARE VERSION|PODMAN |$(style::green $(version::podman))
SOFTWARE VERSION|NODE   |$(style::green $(version::common node))
SOFTWARE VERSION|NPM    |$(style::green $(version::common npm))
SOFTWARE VERSION|YARN   |$(style::green $(version::common yarn))
SOFTWARE VERSION|LERNA  |$(style::green $(version::common lerna))
EOF
}

# ----------------------------------------------------------------
# Print machine info and flags
# ----------------------------------------------------------------
installer::setup_and_install() {
  devbox::exec_if_debug set -x
  setup::dns
  setup::hosts
  installer__base_packages
  installer__epel
  installer__maven
  installer__container_runtime
  [[ "fe" = $1 ]] && installer__fe
  installer__wrap_up
  devbox::exec_if_debug set +x
}