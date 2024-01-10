require style
LOGGING_LEVEL=$(config::get_from_file logging.level)

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