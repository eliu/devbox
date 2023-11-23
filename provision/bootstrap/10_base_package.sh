#!/usr/bin/env bash
#
# Copyright(c) 2020-2023 eliu (eliuhy@163.com)
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
set -e

# Import environment variables and common functions
source /vagrant/devbox.sh

readonly TEMPDIR="$(mktemp -d)"
readonly M2_MAJOR="3"
readonly M2_VERSION="3.9.5"
readonly M2_URL="https://mirrors.aliyun.com/apache/maven/maven-${M2_MAJOR}/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz"

# ----------------------------------------------------------------
# Set up environment variables
# ----------------------------------------------------------------
setup_env() {
  log::info "Setting up environment ..."
  cat > /etc/profile.d/devbox.sh << EOF
export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}
export PATH=\$MAVEN_HOME/bin:/opt/${NODE_FILENAME}/bin:/usr/local/bin:\$PATH
export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)
export TZ=Asia/Shanghai
EOF
  source /etc/profile > /dev/null
}

# ----------------------------------------------------------------
# Setup hosts
# ----------------------------------------------------------------
setup_hosts() {
  log::info "Setting up machine hosts ..."
  if ! cat /etc/hosts | grep dev.$APP_DOMAIN > /dev/null; then
    cat >> /etc/hosts << EOF
$MACHINE_IP dev.$APP_DOMAIN
$MACHINE_IP db.$APP_DOMAIN
$MACHINE_IP redis.$APP_DOMAIN
$MACHINE_IP file.$APP_DOMAIN
EOF
  fi
  hostnamectl set-hostname dev.$APP_DOMAIN
}

# ----------------------------------------------------------------
# Resolve DNS issue
# ----------------------------------------------------------------
resolve_dns() {
  log::info "Find network interface with real internet connection..."
  local network_uuid=
  for uuid in $(nmcli -get-values UUID conn show --active); do
    if [ "auto" = "$(nmcli -terse conn show uuid $uuid | grep ipv4.method | awk -F '[:/]' '{print $2}')" ]; then
    network_uuid=$uuid
    fi
  done

  if [ -z $network_uuid ]; then
    log::warn "Failed to locate correct network interface."
    return 1
  fi

  log::info "Resolving DNS..."
  for nameserver in $(cat /vagrant/config/nameserver.conf); do
    log::info "Adding nameserver $nameserver ..."
    nmcli con mod $network_uuid +ipv4.dns $nameserver
  done

  log::info "Restarting network manager..."
  systemctl restart NetworkManager
}

# ----------------------------------------------------------------
# Change repo mirror to aliyun
# ----------------------------------------------------------------
accelerate_repo() {
  log::info "Acceleratiing your repository..."
  # https://developer.aliyun.com/mirror/rockylinux
  sed -i.bak \
    -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    /etc/yum.repos.d/rocky*.repo
  dnf $(! $DEBUG && printf -- "-q") makecache
}

# ----------------------------------------------------------------
# Install base packages
# ----------------------------------------------------------------
install_base_packages() {
  log::info "Installing base packages ..."
  dnf install $(! $DEBUG && printf -- "-q") -y \
    java-1.8.0-openjdk-devel \
    git \
    python3-pip \
    podman \
    vim
  log::info "Installing compose implementation..."
  su - vagrant <<EOF
pip3 $(! $DEBUG && printf -- "-q") install podman-compose -i https://mirrors.aliyun.com/pypi/simple
EOF
  log::info "Accelerating container registry..."
  mv /etc/containers/registries.conf /etc/containers/registries.conf.bak
  \cp -f /vagrant/config/registries.conf /etc/containers/registries.conf
}

# ----------------------------------------------------------------
# Install Maven
# ----------------------------------------------------------------
install_maven() {
  if sys_already_installed mvn; then
    log::info "Maven has been previously installed."
  else
    log::info "Installing Maven ..."
    log::info "Downloading ${M2_URL}"
    curl -sSL ${M2_URL} -o "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
    log::info "Extracting files to /opt ..."
    tar zxf "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
    # 配置国内源
    mkdir -p $VAGRANT_HOME/.m2
    cp /vagrant/config/maven-settings.xml $VAGRANT_HOME/.m2/settings.xml
    chown -R vagrant:vagrant $VAGRANT_HOME/.m2
  fi
}

# ----------------------------------------------------------------
# Verify all versions of installed components
# ----------------------------------------------------------------
verify_versions() {
  log::info "VERIFY PACKAGE VERSION..."
  cat << EOF | column -t -N "SOFTWARE,VERSION"
  -------- -------
  $(installed java   && echo "OpenJDK $(color::green $(java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}'))")
  $(installed mvn    && echo "Maven   $(color::green $(mvn -version | head -n 1 | awk '{print $3}'))")
  $(installed git    && echo "Git     $(color::green $(git version | awk '{print $3}'))")
  $(installed podman && echo "Podmam  $(color::green $(podman version | grep Version | head -n 1 | awk '{print $2}'))")
EOF
}

{
  DEBUG set -x
  setup_env
  setup_hosts
  resolve_dns
  accelerate_repo
  install_base_packages
  install_maven
  verify_versions
  DEBUG set +x
}
