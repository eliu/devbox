declare -gA module_loaded
#===  FUNCTION  ================================================================
#         NAME: require
#  DESCRIPTION: Import required modules into context
# PARAMETER  X: Module names
#===============================================================================
function require() {
  local module_path
  for module in $@; do
    module_path="/vagrant/lib/$module.sh"
    if [ -f "$module_path" ] && ! [[ -v module_loaded[$module] ]]; then
      # echo "Loading module $module_path"
      module_loaded[$module]=true
      source $module_path
    fi
  done
}

#===  FUNCTION  ================================================================
#         NAME: fmt_dict
#  DESCRIPTION: Format associated array in conjunction with separator
# PARAMETER  1: Name of the associated array
# PARAMETER  2: Separator, default to '=' if not specified
#===============================================================================
function fmt_dict() {
  local -n dict=$1
  local sep=${2:-=}
  for key in ${!dict[@]}; do
    echo "$key $sep ${dict[$key]:-[NONE]}"
  done | sort | column -t
}

#===  FUNCTION  ================================================================
#         NAME: has_command
#  DESCRIPTION: Check if one or more specified commands exists
# PARAMETER  @: Commands separated with spaces
#===============================================================================
function has_command() {
  while [ $# -gt 0 ]; do
    command -v $1 >/dev/null 2>&1 && shift || return
  done
  return 0
}

require tconfig logging
config::load_properties

QUIET_FLAG_Q=$(log::is_verbose_enabled || printf -- "-q")
QUIET_FLAG_S=$(log::is_verbose_enabled || printf -- "-s")
QUIET_STDOUT=$(log::is_verbose_enabled && echo "/dev/stdout" || echo "/dev/null")
QUIET_PULL=$(log::is_verbose_enabled || printf -- "--quiet-pull")
