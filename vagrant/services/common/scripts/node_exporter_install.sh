#!/bin/bash

NODE_EXPORTER_VERSION='1.2.2'
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_DIR='/var/lib/prometheus/node_exporter'
COMMON_DIR='/tmp/common'

mkdir -p "${NODE_EXPORTER_DIR}"
cd /tmp || exit
wget -O node_exporter.tar.gz "${NODE_EXPORTER_URL}"
tar -xzf node_exporter.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter "${NODE_EXPORTER_DIR}"

id -u prometheus >/dev/null 2>&1
if [ $? -ne 0 ]; then
    useradd prometheus -m -d "${NODE_EXPORTER_DIR}"
fi

chown -R prometheus:prometheus "${NODE_EXPORTER_DIR}"
chmod 700 "${NODE_EXPORTER_DIR}"

cp "${COMMON_DIR}/config/node_exporter.service" /usr/lib/systemd/system/
chown root:root /usr/lib/systemd/system/node_exporter.service
chmod 644 /usr/lib/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

systemctl status node_exporter

exit 0
