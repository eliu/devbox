# ----------------------------------------------------------------
# Check if specified commands exists
# #@: commands separated with spaces
# ----------------------------------------------------------------
test::cmd() {
  while [ $# -gt 0 ]; do
    command -v $1 >/dev/null 2>&1 && shift || return
  done
  return 0
}