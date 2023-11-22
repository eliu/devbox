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
source /vagrant/devbox.sh

readonly NODE_VERSION="20.9.0"
readonly NODE_FILENAME="node-v${NODE_VERSION}-linux-x64"
readonly URL="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v${NODE_VERSION}/${NODE_FILENAME}.tar.xz"

post_setup() {
  log::info "Setting up context..."
  echo "export PATH=/opt/${NODE_FILENAME}/bin:/usr/local/bin:\$PATH" >> /etc/profile.d/devbox.sh
  source /etc/profile > /dev/null
  log::info "Accelerating registry..."
  npm config set registry https://registry.npmmirror.com
}

install_node() {
  if ! sys_already_installed npm; then
    log::info "Installing node and npm..."
    log::info "Downloading ${URL}"
    curl -sSL ${URL} -o "${TEMPDIR}/${NODE_FILENAME}.tar.xz"
    tar xf "${TEMPDIR}/${NODE_FILENAME}.tar.xz" -C /opt
    post_setup
  fi
}

install_others() {
  if ! sys_already_installed yarn lerna; then
    log::info "Installing yarn and lerna..."
    npm install -s -g npm
    npm install -s -g yarn
    yarn -s global add lerna
  fi
}

print_versions() {
  log::info "VERIFY PACKAGE VERSION..."
  cat << EOF | column -t -N "SOFTWARE,VERSION"
  -------- -------
  $(installed node  && echo "node  $(color::green $(node -v))")
  $(installed npm   && echo "npm   $(color::green $(npm -v))")
  $(installed yarn  && echo "yarn  $(color::green $(yarn -v))")
  $(installed lerna && echo "lerna $(color::green $(lerna -v))")
EOF
}

install_node
install_others
print_versions