require vagrant logging

ACC_MIRROR_M2="https://mirrors.aliyun.com/apache/maven"
ACC_MIRROR_NODE="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"
ACC_NEED_CACHE=false

# ----------------------------------------------------------------
# Make system cache (right after accelerating repo...)
# Parameters:
# $1 -> force making cache regardless the $ACC_NEED_CACHE switch
# ----------------------------------------------------------------
accelerator::system_cache() {
  if $ACC_NEED_CACHE || [[ $1 = "now" ]]; then
    log::info "Making system cache. This will take a few seconds..."
    dnf $QUIET_FLAG_Q makecache >$QUIET_STDOUT 2>&1
  fi
}

# ----------------------------------------------------------------
# Make cache for vagrant
# ----------------------------------------------------------------
accelerator::user_cache() {
  if $ACC_NEED_CACHE; then
    log::info "Making cache for user 'vagrant'. This will take a few seconds..."
    vg::exec "dnf $QUIET_FLAG_Q makecache >$QUIET_STDOUT 2>&1"
  fi
}

# ----------------------------------------------------------------
# Change repo mirror to aliyun
# ----------------------------------------------------------------
accelerator::repo() {
  grep aliyun /etc/yum.repos.d/rocky.repo > /dev/null 2>&1 || {
    log::info "Accelerating base repo..."
    # https://developer.aliyun.com/mirror/rockylinux
    sed -i.bak \
      -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
      /etc/yum.repos.d/rocky*.repo
    ACC_NEED_CACHE=true
  }
}

# ----------------------------------------------------------------
# Accelerate epel repo
# ----------------------------------------------------------------
accelerator::epel() {
  grep aliyun /etc/yum.repos.d/epel.repo > /dev/null 2>&1 || {
    log::info "Accelerating epel repo..."
    # https://developer.aliyun.com/mirror/epel/?spm=a2c6h.25603864.0.0.43455993b5QGRS
    rm -f /etc/yum.repos.d/epel-cisco-openh264.repo
    sed -i.bak \
      -e 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|' \
      -e 's|^metalink|#metalink|' \
      /etc/yum.repos.d/epel*
    ACC_NEED_CACHE=true
  }
}

# ----------------------------------------------------------------
# Change maven mirror to aliyun
# ----------------------------------------------------------------
accelerator::maven() {
  grep aliyun $VAGRANT_HOME/.m2/settings.xml > /dev/null 2>&1 || {
    log::info "Accelerating maven repo..."
    mkdir -p $VAGRANT_HOME/.m2
    cp /vagrant/etc/maven/settings.xml $VAGRANT_HOME/.m2/settings.xml
    vg::chown $VAGRANT_HOME/.m2
  }
}

# ----------------------------------------------------------------
# Use TAOBAO npm registry
# ----------------------------------------------------------------
accelerator::npm_registry() {
  log::info "Accelerating npm registry..."
  npm config set registry https://registry.npmmirror.com
}

# ----------------------------------------------------------------
# Use aliyun to accelerate pip
# ----------------------------------------------------------------
accelerator::pip() {
  log::info "Accelerating python pip..."
  pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple > /dev/null 2>&1
}