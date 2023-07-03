#!/bin/bash

# Exit script on error
set -e

# Variables
VERSION="1.6.0"
ARCH="linux-amd64"
INSTALL_DIR="/opt/prometheus/exporters/node_exporter_current"
USER="prometheus"
GROUP="prometheus"

# Download and extract node_exporter
wget "https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.${ARCH}.tar.gz"
tar xvfz "node_exporter-${VERSION}.${ARCH}.tar.gz"

# Move the node_exporter binary to the local bin directory
mv "node_exporter-${VERSION}.${ARCH}/node_exporter" /usr/local/bin/

# Create a systemd service file for node_exporter
cat << EOF > /etc/systemd/system/prometheus-node-exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=${USER}
Group=${GROUP}
ExecStart=${INSTALL_DIR}/node_exporter --collector.conntrack --collector.cpu --collector.diskstats --collector.entropy --collector.filefd --collector.filesystem --collector.loadavg --collector.mdadm --collector.meminfo --collector.netdev --collector.netstat --collector.stat --collector.textfile --collector.time --collector.vmstat  --web.listen-address=0.0.0.0:9100 --log.level=info --collector.textfile.directory=/var/log/prometheus/ 
SyslogIdentifier=prometheus_node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Create a system group for prometheus
groupadd --system ${GROUP}

# Create a system user for prometheus
useradd -s /sbin/nologin --system -g ${GROUP} ${USER}

# Create directories for the prometheus installation
mkdir -p ${INSTALL_DIR}

# Move the node_exporter binary to the installation directory
mv /usr/local/bin/node_exporter ${INSTALL_DIR}/node_exporter

# Reload the systemd daemon to recognize the new service
systemctl daemon-reload

# Enable the prometheus-node-exporter service to start on boot
systemctl enable prometheus-node-exporter.service

# Start the prometheus-node-exporter service
systemctl start prometheus-node-exporter.service

########################################################################
########################################################################
#edit the prometheus-server configuration under /etc/prometheus/config.yaml  + /etc/prometheus/instances.yaml
#reload the prometheus server service. 
########################################################################
########################################################################

# global:
#   scrape_interval: 15s
#   evaluation_interval: 15s
# alerting:
#   alertmanagers:
#     - static_configs:
#         - targets:
#           # - alertmanager:9093
# rule_files:
# scrape_configs:
#   # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
#   - job_name: "prometheus"
#     metrics_path: /metrics
#     scheme: http
#     scrape_interval: 15s
#     scrape_timeout: 3s
#     static_configs:
#       - targets: ["localhost:9090"]

#   - job_name: staging
#     scheme: http
#     metrics_path: /metrics
#     scrape_interval: 30s
#     scrape_timeout: 3s
#     file_sd_configs:
#     - files:
#       - '/etc/prometheus/instance_stg.yml' 
#       refresh_interval: 720m

#   - job_name: prod
#     metrics_path: /metrics
#     scheme: http
#     scrape_interval: 45s
#     scrape_timeout: 3s
#     file_sd_configs:
#     - files:
#       - '/etc/prometheus/instance_prod.yml'
#       refresh_interval: 720m

########################################################################
########################################################################
#prometheus service 
########################################################################
########################################################################
# [Unit]
# Description=Prometheus
# Documentation=https://prometheus.io/docs/introduction/overview/
# Wants=network-online.target
# After=network-online.target

# [Service]
# Type=simple
# User=root
# Group=root
# ExecReload=/bin/kill -HUP $MAINPID
# ExecStart=/usr/local/bin/prometheus   --config.file=/etc/prometheus/config.yaml   --storage.tsdb.path=/var/lib/prometheus   --web.console.templates=/etc/prometheus/consoles   --web.console.libraries=/etc/prometheus/console_libraries   --web.listen-address=0.0.0.0:9090   --web.external-url= --log.level=debug

# SyslogIdentifier=prometheus
# Restart=always

# [Install]
# WantedBy=multi-user.target