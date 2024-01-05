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