#!/usr/bin/env bash
set -e
source /vagrant/include/devbox.sh
require vagrant cri
SVC_HOME=$VAGRANT_HOME/.local/basesvc
#===  FUNCTION  ================================================================
#         NAME: basesvc::init
#  DESCRIPTION: Initialize workspace for container services
#       RUN AS: vagrant
# PARAMETER  1: ---
#===============================================================================
basesvc::init() {
  has_command $CRI_COMMAND || log::fatal "You need enable container option first."

  [[ -d $SVC_HOME ]] || {
    log::info "Deploying base services..."
    mkdir -p "$SVC_HOME"
    \cp -r /vagrant/etc/basesvc/* "$SVC_HOME"
    vg::enable_linger
  }
}

#===  FUNCTION  ================================================================
#         NAME: basesvc::init
#  DESCRIPTION: Start base services: mysql, redis, minio
#       RUN AS: vagrant
# PARAMETER  1: ---
#===============================================================================
basesvc::up() {
  cd "$SVC_HOME"
  log::info "Starting base services..."
  cri::compose up $QUIET_PULL -d >$QUIET_STDOUT 2>&1
}

#===  FUNCTION  ================================================================
#         NAME: basesvc::init
#  DESCRIPTION: Print running status of base services
#       RUN AS: vagrant
# PARAMETER  1: ---
#===============================================================================
basesvc::ps() {
  cd "$SVC_HOME"
  cri::compose ps
}

# Main entrypoint 
{
  case $1 in
  up)
    basesvc::init
    basesvc::up
    ;;
  ps)
    basesvc::ps
    ;;
  *)
    log::fatal "Bad argument $1"
    ;;
  esac
}
