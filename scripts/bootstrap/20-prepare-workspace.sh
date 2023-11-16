#!/usr/bin/env bash
set -e

# 初始化公共环境变量及函数
. /vagrant/scripts/common/profile.env

{
  DEBUG set -x
  info "Deploying base services ..."
  mkdir -p "$APP_HOME"
  cp -r /vagrant/base-service "$APP_HOME"
  chown_vagrant "$APP_HOME"
  DEBUG set +x
}
