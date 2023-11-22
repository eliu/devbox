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

# 初始化公共环境变量及函数
source /vagrant/devbox.sh

{
  DEBUG set -x
  log::info "Deploying base services ..."
  mkdir -p "$APP_HOME"
  cp -r /vagrant/base-services "$APP_HOME"
  vagrant::chown "$APP_HOME"
  vagrant::enable_linger
  DEBUG set +x
}
