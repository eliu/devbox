#!/usr/bin/env bash
set -e
source /vagrant/scripts/common/profile.env

readonly NODE_VERSION="17.9.1"
readonly NODE_FILENAME="node-v${NODE_VERSION}-linux-x64"
readonly URL="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v${NODE_VERSION}/${NODE_FILENAME}.tar.xz"

setup_context() {
  info "Setting up context..."
  echo "export PATH=/opt/${NODE_FILENAME}/bin:/usr/local/bin:\$PATH" >> /etc/profile.d/quickstart.sh
  source /etc/profile > /dev/null
}

install_node() {
  if ! sys_already_installed npm; then
    info "Installing node and npm..."
    info "Downloading ${URL}"
    curl -sSL ${URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    setup_context
  fi
}

install_others() {
  if ! sys_already_installed yarn lerna; then
    info "Installing yarn and lerna..."
    npm install --silent -g yarn lerna --registry=https://registry.npmmirror.com
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