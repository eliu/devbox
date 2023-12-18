#
# Copyright(c) 2020-2023 Liu Hongyu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
source /vagrant/lib/modules/vagrant.sh
export ACC_MIRROR_M2="https://mirrors.aliyun.com/apache/maven"
export ACC_MIRROR_NODE="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"

# ----------------------------------------------------------------
# Make cache for repo (right after accelerating repo...)
# Scope: private
# ----------------------------------------------------------------
accelerator__make_cache() {
  log::info "Making cache. This may take a few seconds..."
  dnf $(! $DEBUG && printf -- "-q") makecache
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
    accelerator__make_cache
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
    accelerator__make_cache
  }
}

# ----------------------------------------------------------------
# Change maven mirror to aliyun
# ----------------------------------------------------------------
accelerator::maven() {
  grep aliyun $VAGRANT_HOME/.m2/settings.xml > /dev/null 2>&1 || {
    log::info "Accelerating maven repo..."
    mkdir -p $VAGRANT_HOME/.m2
    cp /vagrant/etc/maven-settings.xml $VAGRANT_HOME/.m2/settings.xml
    vg::chown $VAGRANT_HOME/.m2
  }
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

# ----------------------------------------------------------------
# Use aliyun to accelerate pip
# ----------------------------------------------------------------
accelerator::pip() {
  log::info "Accelerating python pip..."
  pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple > /dev/null 2>&1
}