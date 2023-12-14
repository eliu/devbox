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
source /vagrant/devbox.sh
# ----------------------------------------------------------------
# Print os info
# ----------------------------------------------------------------
version::os() {
  cat /etc/system-release
}

# ----------------------------------------------------------------
# Print current static ip address
# ----------------------------------------------------------------
version::ip() {
  ip -br -f inet addr | grep 192 | awk -F'[ /]+' '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed EPEL repo version
# ----------------------------------------------------------------
version::epel(){
  dnf list installed "epel*" 2>/dev/null | grep epel | awk '{print $1"."$2}'
}

# ----------------------------------------------------------------
# Print currently installed java version
# ----------------------------------------------------------------
version::java() {
  installed java && java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}'
}

# ----------------------------------------------------------------
# Print currently installed maven version
# ----------------------------------------------------------------
version::maven() {
  installed mvn && mvn -version | head -n 1 | awk '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed git version
# ----------------------------------------------------------------
version::git() {
  installed git && git version | awk '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed podman version
# ----------------------------------------------------------------
version::podman() {
  installed podman && podman version | grep Version | head -n 1 | awk '{print $2}'
}

# ----------------------------------------------------------------
# Print version of the component commonly using form `command -v`
# ----------------------------------------------------------------
version::common() {
  installed $1 && $1 -v
}