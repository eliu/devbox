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

require test config logging

QUIET_FLAG_Q=$(log::is_verbose_enabled || printf -- "-q")
QUIET_FLAG_S=$(log::is_verbose_enabled || printf -- "-s")
QUIET_STDOUT=$(log::is_verbose_enabled && echo "/dev/stdout" || echo "/dev/null")
QUIET_PULL=$(log::is_verbose_enabled || printf -- "--quiet-pull")
config::load_from_file
