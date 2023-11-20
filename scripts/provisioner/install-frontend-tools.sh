#!/usr/bin/env bash
set -e
source /vagrant/scripts/common/profile.env

readonly NODE_VERSION="20.9.0"
readonly NODE_FILENAME="node-v${NODE_VERSION}-linux-x64"
readonly URL="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v${NODE_VERSION}/${NODE_FILENAME}.tar.xz"

post_setup() {
  info "Setting up context..."
  echo "export PATH=/opt/${NODE_FILENAME}/bin:/usr/local/bin:\$PATH" >> /etc/profile.d/devbox.sh
  source /etc/profile > /dev/null
  info "Accelerating registry..."
  npm config set registry https://registry.npmmirror.com
}

install_node() {
  if ! sys_already_installed npm; then
    info "Installing node and npm..."
    info "Downloading ${URL}"
    curl -sSL ${URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    post_setup
  fi
}

install_others() {
  if ! sys_already_installed yarn lerna; then
    info "Installing yarn and lerna..."
    npm install -s -g npm
    npm install -s -g yarn
    yarn -s global add lerna
  fi
}

print_versions() {
  info "ALL INSTALLED TOOLS WITH VERSIONS ARE"
  sys_already_installed node && info "node -> `node -v`"
  sys_already_installed npm && info "npm -> `npm -v`"
  sys_already_installed yarn && info "yarn -> `yarn -v`"
  sys_already_installed lerna && info "lerna -> `lerna -v`"
}

install_node
install_others
print_versions