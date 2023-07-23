#!/bin/bash
#### Setup User and group for the exporters #####
echo "Creating group + user for node exporters"
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus
#### Setup prometheus directories ###############
mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
mkdir /opt/prometheus 
mkdir /opt/prometheus/exporters 
mkdir /opt/prometheus/exporters/node_exporter_current/
#### Node Exporter configuration ################
echo "Downloading the node-exporter"
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.0.linux-amd64.tar.gz 
mv node_exporter-1.6.0.linux-amd64/node_exporter /opt/prometheus/exporters/node_exporter_current/node_exporter
echo "Downloading the squid-exporter"
wget https://github.com/boynux/squid-exporter/releases/download/v1.10.4/squid-exporter
mv squid-exporter /usr/local/bin/
chmod +x /usr/local/bin/squid-exporter
#### Configure the service #######################
echo "Creating the node-exporter conf file"
cat << EOF > /etc/systemd/system/prometheus-node-exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/opt/prometheus/exporters/node_exporter_current/node_exporter --collector.conntrack --collector.cpu --collector.diskstats --collector.entropy --collector.filefd --collector.filesystem --collector.loadavg --collector.mdadm --collector.meminfo --collector.netdev --collector.netstat --collector.stat --collector.textfile --collector.time --collector.vmstat  --web.listen-address=0.0.0.0:8443 --log.level=info --collector.textfile.directory=/var/log/prometheus/ 
SyslogIdentifier=prometheus_node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
#################################################
echo "Creating the squid-exporter conf file"
cat << EOF > /etc/systemd/system/squid-exporter.service
[Unit]
Description=Squid Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/squid-exporter -listen :9301

[Install]
WantedBy=multi-user.target
EOF
#### Lounch the services #########################
systemctl daemon-reload
systemctl enable prometheus-node-exporter.service
systemctl enable squid-exporter.service
systemctl start prometheus-node-exporter.service
systemctl start squid-exporter.service