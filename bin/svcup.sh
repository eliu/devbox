#!/usr/bin/env bash
set -e
source /vagrant/include/devbox.sh
source $MODULE_ROOT/basesvc.sh
log::is_debug_enabled && set -x || true
basesvc::init
basesvc::up
log::is_debug_enabled && set +x || true