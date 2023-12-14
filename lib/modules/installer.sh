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
source /vagrant/lib/modules/version.sh
source /vagrant/lib/modules/setup.sh
source /vagrant/lib/modules/accelerator.sh

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
# ----------------------------------------------------------------
installer::base_packages() {
  sys_already_installed java vim git pip3 || {
    log::info "Accelerating base repo..."
    accelerator::repo
    
    log::info "Installing base packages that may take some time..."
    dnf install $IS_QUIET -y java-1.8.0-openjdk-devel git vim python3-pip
    
    log::info "Accelerating python pip..."
    accelerator::pip
    
    setup::context "TZ" "export TZ=Asia/Shanghai"
    setup::context "PATH" "export PATH=/usr/local/bin:\$PATH"
    setup::context "JAVA_HOME" "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
  }
}

# ----------------------------------------------------------------
# Install and accelerate epel repo
# ----------------------------------------------------------------
installer::epel() {
  dnf list installed "epel*" > /dev/null 2>&1 || {
    log::info "Setting up epel repo..."
    dnf install $IS_QUIET -y https://mirrors.aliyun.com/epel/epel-release-latest-9.noarch.rpm
    accelerator::epel
  }
}

installer::container_runtime() {
  sys_already_installed podman || {
    log::info "Installing podman..."
    dnf install $IS_QUIET -y podman

    log::info "Installing podman compose as user vagrant..."
    vagrant::exec "pip3 $IS_QUIET install podman-compose"
    accelerator::container_registry
  }
}

# ----------------------------------------------------------------
# Install Maven
# ----------------------------------------------------------------
installer::maven() {
  sys_already_installed mvn || {
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
# ----------------------------------------------------------------
installer::fe() {
  sys_already_installed npm || {
    log::info "Installing node and npm..."
    log::info "Downloading ${NODE_URL}"
    curl -sSL ${NODE_URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    setup::context "PATH" "export PATH=/opt/${NODE_FILENAME}/bin:\$PATH"
    accelerator::npm_registry
  }

  sys_already_installed yarn lerna || {
    log::info "Installing yarn and lerna..."
    npm install -s -g npm
    npm install -s -g yarn
    yarn -s global add lerna
  }
}