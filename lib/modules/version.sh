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
# ----------------------------------------------------------------
# Print os info
# ----------------------------------------------------------------
version::os() {
  cat /etc/system-release
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
  test::cmd java && java -version 2>&1 | head -n 1 | awk -F'"' '{print $2}'
}

# ----------------------------------------------------------------
# Print currently installed maven version
# ----------------------------------------------------------------
version::maven() {
  test::cmd java && test::cmd mvn && mvn -version | head -n 1 | awk '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed git version
# ----------------------------------------------------------------
version::git() {
  test::cmd git && git version | awk '{print $3}'
}

# ----------------------------------------------------------------
# Print currently installed podman version
# ----------------------------------------------------------------
version::podman() {
  test::cmd podman && podman version | grep Version | head -n 1 | awk '{print $2}'
}

# ----------------------------------------------------------------
# Print currently installed python3 version
# ----------------------------------------------------------------
version::python3() {
  test::cmd python3 && python3 -V | cut -d' ' -f2
}

# ----------------------------------------------------------------
# Print currently installed pip3 version
# ----------------------------------------------------------------
version::pip3() {
  test::cmd pip3 && pip3 -V | cut -d' ' -f2
}

# ----------------------------------------------------------------
# Print version of the component commonly using form `command -v`
# ----------------------------------------------------------------
version::of() {
  test::cmd $1 && $1 -v
}