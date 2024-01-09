export MODULE_ROOT="/vagrant/lib"
source $MODULE_ROOT/test.sh
source $MODULE_ROOT/config.sh
source $MODULE_ROOT/logging.sh
export QUIET_FLAG_Q=$(log::is_verbose_enabled || printf -- "-q")
export QUIET_FLAG_S=$(log::is_verbose_enabled || printf -- "-s")
export QUIET_STDOUT=$(log::is_verbose_enabled && echo "/dev/stdout" || echo "/dev/null")
export QUIET_PULL=$(log::is_verbose_enabled || printf -- "--quiet-pull")
config::load_from_file
