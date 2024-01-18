require logging
config_file="/vagrant/etc/devbox.properties"
# Bash make declaration of associated array as local variable
# by default. We have to use -g option to make it globally visible
# especially when sourcing this file inside a function.
declare -gA cache

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
config::load_properties() {
  while IFS='=' read -r prop value; do
    cache[$prop]=$value
  done < <(cat $config_file | sed -e '/^[[:space:]]*$/d' -e '/^#/d')

  log::verbose "All cached items (${#cache[@]}) from config file are:"
  log::is_verbose_enabled && fmt_dict cache || true
}