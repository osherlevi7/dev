#!/bin/bash
set -e

echo " Run GCR login for bootstrap time"
/usr/local/bin/gcr_docker_login.sh

echo "Run GCR login in cron for every 8 hours"
/usr/sbin/crond -b -l 8

echo "Run watchtower" 
exec /watchtower "$@"
