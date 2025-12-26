require logging config version setup accelerator cri vagrant components/network
require components/openjdk
require components/maven
require components/epel
require components/pip
require components/git
require components/npm
require components/cri


# ----------------------------------------------------------------
# Pre-process before installation
# Scope: private
# ----------------------------------------------------------------
installer::preprocess() {
  setup::add_context "LANG" "export LANG=en_US.UTF-8"
  setup::add_context "LC_ALL" "export LC_ALL=en_US.UTF-8"
  setup::add_context "TZ" "export TZ=Asia/Shanghai"
  setup::add_context "PATH" "export PATH=/usr/local/bin:\$PATH"
  setup::dns
  setup::hosts
  repo::accelerate
  cri::config_repo
  repo::system_cache
}

# ----------------------------------------------------------------
# Post-process after installation
# Scope: private
# ----------------------------------------------------------------
installer::postprocess() {
  repo::system_cache
  repo::user_cache
}

# ----------------------------------------------------------------
# Print machine info and flags
# Scope: private
# ----------------------------------------------------------------
installer::wrap_up() {
  network::gather_facts
  log::verbose "Installation complete! Wrap it up..."
  cat << EOF | column -t -s "|" -N CATEGORY,NAME,VALUE
----------------|----|-----
PROPERTY|MACHINE_OS  |$(style::green $(version::os))
PROPERTY|MACHINE_IP  |$(style::green ${network_facts[ip]})
PROPERTY|USING_DNS   |$(style::green ${network_facts[dns]})
----------------|----|-----
$(config::get installer.git.enabled && echo "SOFTWARE VERSION|GIT|$(style::green $(git::version))")
$(config::get installer.epel.enabled && echo "SOFTWARE VERSION|EPEL|$(style::green $(epel::version))")
$(config::get installer.openjdk.enabled && echo "SOFTWARE VERSION|OPENJDK|$(style::green $(openjdk::version))")
$(config::get installer.maven.enabled && echo "SOFTWARE VERSION|MAVEN|$(style::green $(maven::version))")
SOFTWARE VERSION|PIP3|$(style::green $(pip3::version))
$(config::get installer.container.enabled && echo "SOFTWARE VERSION|$CRI_COMMAND|$(style::green $(cri::version))")
$(config::get installer.npm.enabled && echo "SOFTWARE VERSION|NODE|$(style::green $(version::of node))")
$(config::get installer.npm.enabled && echo "SOFTWARE VERSION|NPM|$(style::green $(version::of npm))")
EOF
}

# ----------------------------------------------------------------
# Print machine info and flags
# ----------------------------------------------------------------
installer::main() {
  log::is_debug && set -x || true
  installer::preprocess
  pip3::installer
  cri::installer
  git::installer
  openjdk::installer
  maven::installer
  npm::installer
  epel::installer
  installer::postprocess
  installer::wrap_up
  log::is_debug && set +x || true
}
