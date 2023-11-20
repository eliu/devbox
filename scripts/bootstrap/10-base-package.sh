#!/usr/bin/env bash
set -e

MACHINE_IP="$1"
TEMPDIR="$(mktemp -d)"
M2_MAJOR="3"
M2_VERSION="3.9.5"

# 初始化公共环境变量及函数
. /vagrant/scripts/common/profile.env

# ----------------------------------------------------------------
# 设置环境变量
# ----------------------------------------------------------------
setup_env() {
  info "Setting up environment ..."
  cat > /etc/profile.d/devbox.sh << EOF
export MAVEN_HOME=/opt/apache-maven-${M2_VERSION}
export PATH=\$MAVEN_HOME/bin:/opt/${NODE_FILENAME}/bin:/usr/local/bin:\$PATH
export JAVA_HOME=$(readlink -f /etc/alternatives/java_sdk_openjdk)
export TZ=Asia/Shanghai
EOF
  . /etc/profile > /dev/null
}

# ----------------------------------------------------------------
# 设置地址IP映射
# ----------------------------------------------------------------
setup_hosts() {
  info "Setting up machine hosts ..."
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
# 解决 DNS 无法解析导致安装包超时的问题
# ----------------------------------------------------------------
resolve_dns() {
  info "Find network interface with real internet connection..."
  local network_uuid=
  for uuid in $(nmcli -get-values UUID conn show --active); do
    if [ "auto" = "$(nmcli -terse conn show uuid $uuid | grep ipv4.method | awk -F '[:/]' '{print $2}')" ]; then
    network_uuid=$uuid
    fi
  done

  if [ -z $network_uuid ]; then
    warn "Failed to locate correct network interface."
    return 1
  fi

  info "Resolving DNS..."
  for nameserver in $(cat /vagrant/user-config/nameserver.conf); do
    info "Adding nameserver $nameserver ..."
    nmcli con mod $network_uuid +ipv4.dns $nameserver
  done

  info "Restarting network manager..."
  systemctl restart NetworkManager
}

# ----------------------------------------------------------------
# 替换默认的软件源
# ----------------------------------------------------------------
accelerate_repo() {
  info "Acceleratiing your repository..."
  # https://developer.aliyun.com/mirror/rockylinux
  sed -i.bak \
    -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    /etc/yum.repos.d/rocky*.repo
  dnf makecache
}

# ----------------------------------------------------------------
# 安装基础依赖包
# ----------------------------------------------------------------
install_base_packages() {
  info "Installing base packages ..."
  dnf install -y \
    java-1.8.0-openjdk-devel \
    git \
    python3-pip \
    podman \
    vim
  info "Installing compose implementation..."
  su - vagrant <<EOF
pip3 install podman-compose -i https://mirrors.aliyun.com/pypi/simple
EOF
  info "Accelerating container registry..."
  mv /etc/containers/registries.conf /etc/containers/registries.conf.bak
  \cp -f /vagrant/user-config/registries.conf /etc/containers/registries.conf
}

# ----------------------------------------------------------------
# 安装 Maven
# ----------------------------------------------------------------
install_maven() {
  if sys_already_installed mvn; then
    info "Maven has been previously installed."
  else
    info "Installing Maven ..."
    local download_url=https://mirrors.aliyun.com/apache/maven/maven-${M2_MAJOR}/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz
    info "Downloading ${download_url}"
    curl -sSL ${download_url} -o "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz"
    info "Extracting files to /opt ..."
    tar zxf "${TEMPDIR}/apache-maven-${M2_VERSION}-bin.tar.gz" -C /opt > /dev/null
    # 配置国内源
    mkdir -p $VAGRANT_HOME/.m2
    cp /vagrant/user-config/maven-settings.xml $VAGRANT_HOME/.m2/settings.xml
    chown -R vagrant:vagrant $VAGRANT_HOME/.m2
  fi
}

# ----------------------------------------------------------------
# 确认所有软件的版本
# ----------------------------------------------------------------
verify_versions() {
  info "VERIFY PACKAGE VERSION..."
  sys_already_installed node   && echo "Node   version: $(node -v)"
  sys_already_installed npm    && echo "NPM    version: $(npm -v)"
  sys_already_installed lerna  && echo "lerna  version: $(lerna -v)"
  sys_already_installed yarn   && echo "yarn   version: $(yarn -v)"
  sys_already_installed java   && echo "java   version: $(java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}')"
  sys_already_installed mvn    && echo "mvn    version: $(mvn -version | head -n 1 | awk '{print $3}')"
  sys_already_installed git    && echo "git    version: $(git version | awk '{print $3}')"
  sys_already_installed podman && echo "podman version: $(podman version | grep Version | head -n 1 | awk '{print $2}')"
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
