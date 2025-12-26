require logging
require config
require accelerator


# ----------------------------------------------------------------
# Install and accelerate epel repo
# Scope: private
# ----------------------------------------------------------------
epel::installer() {
  config::get installer.epel.enabled && {
    dnf list installed "epel*" > /dev/null 2>&1 || {
      log::info "Installing epel-release..."
      dnf install $QUIET_FLAG_Q -y epel-release >$QUIET_STDOUT 2>&1
      epel::accelerate
    }
  } || {
    dnf list installed "epel*" > /dev/null 2>&1 && {
      log::info "Uninstalling epel-release..."
      dnf remove $QUIET_FLAG_Q -y epel-release >$QUIET_STDOUT 2>&1
    } || true
  }
}

epel::accelerate() {
  grep aliyun /etc/yum.repos.d/epel.repo > /dev/null 2>&1 || {
    log::info "Accelerating epel repo..."
    # https://developer.aliyun.com/mirror/epel/?spm=a2c6h.25603864.0.0.43455993b5QGRS
    rm -f /etc/yum.repos.d/epel-cisco-openh264.repo
    sed -i.bak \
      -e 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|' \
      -e 's|^metalink|#metalink|' \
      /etc/yum.repos.d/epel*
    repo::notify_cache
  }
}

epel::version() {
  dnf list installed "epel*" 2>/dev/null | grep epel | awk '{print $1"."$2}'
}
