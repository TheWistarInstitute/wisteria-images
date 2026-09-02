#!/bin/sh
# Warewulf image cleanup hook.
# Warewulf runs /etc/warewulf/image_exit.sh after image shell/exec and before rebuilds.

set -eu

dnf clean all || true
rm -rf /var/cache/dnf /var/cache/yum
rm -rf /tmp/* /var/tmp/*
rm -rf /run/*

# Logs in a stateless compute-node image are just archaeological sediment.
find /var/log -type f -exec truncate -s 0 {} + 2>/dev/null || true
