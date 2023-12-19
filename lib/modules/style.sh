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
STYLE_GREEN="\e[32m"
STYLE_YELLOW="\e[33m"
STYLE_RED="\e[91m"
STYLE_CYAN="\e[36m"
STYLE_RESET="\e[39m"

style::green() { echo -e "$STYLE_GREEN$@$STYLE_RESET"
}
style::yellow() { echo -e "$STYLE_YELLOW$@$STYLE_RESET"
}
style::red() { echo -e "$STYLE_RED$@$STYLE_RESET"
}
style::cyan() { echo -e "$STYLE_CYAN$@$STYLE_RESET"
}