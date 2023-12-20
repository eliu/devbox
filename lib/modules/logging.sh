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
source $MODULE_ROOT/style.sh
LOGGING_LEVEL=$(config::get logging.level)

# ----------------------------------------------------------------
# Logging message at info level
# ----------------------------------------------------------------
log::info() { echo $(style::green  "[INFO]") $@
}
# ----------------------------------------------------------------
# Logging message at warning level
# ----------------------------------------------------------------
log::warn() { echo $(style::yellow "[WARN] $@")
}
# ----------------------------------------------------------------
# Logging message at fatal level
# ----------------------------------------------------------------
log::fatal() { echo $(style::red "[FATA] $@"); exit 1
}
# ----------------------------------------------------------------
# Logging a verbose message
# ----------------------------------------------------------------
log::verbose() { 
  log::is_verbose_enabled && echo $(style::cyan "VERBOSE: $@") || true
}
# ----------------------------------------------------------------
# Check if we're in verbose mode or lower level logging
# ----------------------------------------------------------------
log::is_verbose_enabled() {
  [[ $LOGGING_LEVEL =~ debug|verbose ]]
}
# ----------------------------------------------------------------
# Check if we're in debug mode
# ----------------------------------------------------------------
log::is_debug_enabled() {
  [[ $LOGGING_LEVEL =~ debug ]]
}