#!/bin/bash
set -e

# Run GCR login for bootstrap time
/usr/local/bin/gcr_docker_login.sh

# Run GCR login in cron for every 8 hours
/usr/sbin/crond -b -l 8

# Run watchtower as a non-root user
exec su-exec appuser /watchtower "$@"
