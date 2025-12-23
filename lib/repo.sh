require vagrant logging

ACC_NEED_CACHE=false

# ----------------------------------------------------------------
# Make system cache (right after accelerating repo...)
# Parameters:
# $1 -> force making cache regardless the $ACC_NEED_CACHE switch
# ----------------------------------------------------------------
repo::system_cache() {
  if $ACC_NEED_CACHE; then
    log::info "Making system cache. This will take a few seconds..."
    dnf $QUIET_FLAG_Q makecache >$QUIET_STDOUT 2>&1
  fi
}

# ----------------------------------------------------------------
# Make cache for vagrant
# ----------------------------------------------------------------
repo::user_cache() {
  if $ACC_NEED_CACHE; then
    log::info "Making cache for user 'vagrant'. This will take a few seconds..."
    vg::exec "dnf $QUIET_FLAG_Q makecache >$QUIET_STDOUT 2>&1"
  fi
}

# ----------------------------------------------------------------
# Change repo mirror to aliyun
# ----------------------------------------------------------------
repo::accelerate() {
  grep aliyun /etc/yum.repos.d/rocky.repo > /dev/null 2>&1 || {
    log::info "Accelerating base repo..."
    # https://developer.aliyun.com/mirror/rockylinux
    sed -i.bak \
      -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
      /etc/yum.repos.d/rocky*.repo
    repo::notify_cache
  }
}

# ----------------------------------------------------------------
# Mark flag to make cache later
# ----------------------------------------------------------------
repo::notify_cache() {
  ACC_NEED_CACHE=true
}
