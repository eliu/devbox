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
readonly GRN="\e[32m"        # green color
readonly YLW="\e[33m"        # yellow color
readonly RED="\e[91m"        # red color
readonly RST="\e[39m"        # reset color

color::green() { echo -e "$GRN$@$RST"
}
color::yellow() { echo -e "$YLW$@$RST"
}
color::red() { echo -e "$RED$@$RST"
}