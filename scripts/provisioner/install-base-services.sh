#!/usr/bin/env bash
set -e

source /vagrant/scripts/common/profile.env
cd "$APP_HOME/base-service"
sys_already_installed podman-compose && podman-compose up -d mysql redis minio
