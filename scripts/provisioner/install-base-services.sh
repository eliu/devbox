#!/usr/bin/env bash
set -e

{
  . /vagrant/scripts/common/profile.env
  cd "$APP_HOME/base-service"
  docker-compose up -d mysql redis minio
}
