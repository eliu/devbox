require logging
config_file="/vagrant/etc/devbox.properties"
# Bash make declaration of associated array as local variable
# by default. We have to use -g option to make it globally visible
# especially when sourcing this file inside a function.
declare -gA config_cache

# ----------------------------------------------------------------
# Parse value from config
# Parameters
# $1 -> key
# $1 -> raw value to be parsed
# ----------------------------------------------------------------
config::parsevalue() {
  [[ $1 =~ enabled$ ]] && {
    case $2 in
      "true") return 0 ;;
      "false") return 1 ;;
      *) return 22;;
    esac
  } || echo $2
}

# ----------------------------------------------------------------
# Strip both leading and trailing whitespaces.
# Parameters
# $1 -> string to be stripped
# ----------------------------------------------------------------
config::strip() {
  echo $1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# ----------------------------------------------------------------
# Get property from config_cache
# $1 -> property name
# ----------------------------------------------------------------
config::get() {
  config::parsevalue $1 ${config_cache[$1]}
}

# ----------------------------------------------------------------
# Load all properties into config_cache
# ----------------------------------------------------------------
config::load_properties() {
  while IFS='=' read -r prop value; do
    config_cache[$(config::strip $prop)]=$(config::strip $value)
  done < <(cat $config_file | sed -e '/^[[:space:]]*$/d' -e '/^#/d')

  log::is_verbose && fmt_dict config_cache || true
  log::verbose "(${#config_cache[@]}) properties already cached."
}
