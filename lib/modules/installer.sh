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
source /vagrant/lib/modules/setup.sh
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
  log::info "Installing base packages that may take some time..."
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
  setup::context "TZ" "export TZ=Asia/Shanghai"
  setup::context "PATH" "export PATH=/usr/local/bin:\$PATH"
  setup::context "JAVA_HOME" "export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)"
}

# ----------------------------------------------------------------
# Install Maven
# ----------------------------------------------------------------
installer::maven() {
  if sys_already_installed mvn; then
    log::info "Maven already existed. Skip installation..."
    return 0
  fi
  log::info "Installing Maven..."
  log::info "Downloading ${M2_URL}"
  curl -sSL ${M2_URL} -o "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
  log::info "Extracting files to /opt..."
  tar zxf "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
  accelerator::maven
  setup::context "MAVEN_HOME" "export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}"
  setup::context "PATH" "export PATH=\$MAVEN_HOME/bin:\$PATH"
}

# ----------------------------------------------------------------
# Install frontend tools
# ----------------------------------------------------------------
installer::fe() {
  if sys_already_installed npm; then
    log::info "NPM already existed. Skip installation..."
  else
    log::info "Installing node and npm..."
    log::info "Downloading ${NODE_URL}"
    curl -sSL ${NODE_URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    setup::context "PATH" "export PATH=/opt/${NODE_FILENAME}/bin:\$PATH"
    accelerator::npm_registry
  fi

  if sys_already_installed yarn lerna; then
    log::info "Yarn and Lerna already existed. Skip installation..."
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