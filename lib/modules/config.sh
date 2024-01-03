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
config_file="/vagrant/etc/devbox.properties"
declare -A cache

# ----------------------------------------------------------------
# Parse value from config
# Parameters
# $1 -> key
# $1 -> raw value to be parsed
# ----------------------------------------------------------------
config__parse() {
  [[ $1 =~ enabled$ ]] && {
    case $2 in
      "true") return 0 ;;
      "false") return 1 ;;
      *) return 22;;
    esac
  } || echo $2
}

# ----------------------------------------------------------------
# Get property directly from file
# This is used when config module does not load in time.
# $1 -> property name
# ----------------------------------------------------------------
config::get_from_file() {
  config__parse $1 $(grep "^$1" $config_file | cut -d'=' -f2 | awk '{$1=$1;print}')
}

# ----------------------------------------------------------------
# Get property from cache
# $1 -> property name
# ----------------------------------------------------------------
config::get() {
  config__parse $1 ${cache[$1]}
}

# ----------------------------------------------------------------
# Load all properties into cache
# ----------------------------------------------------------------
config::load_from_file() {
  while IFS='=' read -r prop value; do
    cache[$prop]=$value
  done < <(cat $config_file | sed -e '/^[[:space:]]*$/d' -e '/^#/d')

  if log::is_verbose_enabled; then
    log::verbose "All cached items (${#cache[@]}) from config file are:"
    for prop in ${!cache[@]}; do
      log::verbose "$prop -> ${cache[$prop]}"
    done | sort | column -t
  fi
}