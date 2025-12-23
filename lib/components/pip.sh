require logging


pip3::installer() {
  has_command pip3 || {
    log::info "Installing python3-pip..."
    dnf install $QUIET_FLAG_Q -y python3-pip >$QUIET_STDOUT
    pip3::accelerate
  }
}

pip3::accelerate() {
  log::info "Accelerating python pip..."
  pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple > /dev/null 2>&1
}

pip3::version() {
  has_command pip3 && pip3 -V | cut -d' ' -f2
}

pip3::python_version() {
  has_command python3 && python3 -V | cut -d' ' -f2
}