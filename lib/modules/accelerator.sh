source /vagrant/devbox.sh
source /vagrant/lib/modules/vagrant.sh

export PIP3_MIRROR="https://mirrors.aliyun.com/pypi/simple"
export M2_MIRROR="https://mirrors.aliyun.com/apache/maven"
export NODE_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"

# ----------------------------------------------------------------
# Change maven mirror to aliyun
# ----------------------------------------------------------------
accelerator::maven() {
  mkdir -p $VAGRANT_HOME/.m2
  cp /vagrant/etc/maven-settings.xml $VAGRANT_HOME/.m2/settings.xml
  vagrant::chown $VAGRANT_HOME/.m2
}

# ----------------------------------------------------------------
# Change repo mirror to aliyun
# ----------------------------------------------------------------
accelerator::repo() {
  log::info "Accelerating your repository..."
  # https://developer.aliyun.com/mirror/rockylinux
  sed -i.bak \
    -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    /etc/yum.repos.d/rocky*.repo
  dnf $(! $DEBUG && printf -- "-q") makecache
}

# ----------------------------------------------------------------
# Use container registry for China
# ----------------------------------------------------------------
accelerator::container_registry() {
  log::info "Accelerating container registry..."
  mv /etc/containers/registries.conf /etc/containers/registries.conf.bak
  \cp -f /vagrant/etc/registries.conf /etc/containers/registries.conf
}

# ----------------------------------------------------------------
# Use TAOBAO npm registry
# ----------------------------------------------------------------
accelerator::npm_registry() {
  log::info "Accelerating npm registry..."
  npm config set registry https://registry.npmmirror.com
}
