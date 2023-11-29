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

# Change owner to vagrant
vagrant::chown() {
  chown -R vagrant:vagrant $1
}

# Fix the following error that will cause all running containers stopped unexpectly.
# ERRO[0000] Refreshing container <containerID>: 
# error acquiring lock 0 for container <containerID>: file exists
# ---
# Issue: https://github.com/containers/podman/issues/16784#issuecomment-1711364992
vagrant::enable_linger() {
  loginctl enable-linger vagrant
}