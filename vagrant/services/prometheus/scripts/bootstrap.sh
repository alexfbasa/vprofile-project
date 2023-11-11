#!/bin/bash
PROMETHEUS='https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz'
PROM_DIR='/var/lib/prometheus'
PROM_TMP_SRC_DIR='/tmp/prometheus'
COMMON_DIR='/tmp/common'

if curl --output /dev/null --silent --head --fail "$PROMETHEUS"; then
    echo "URL $PROMETHEUS available."
else
    echo "URL $PROMETHEUS not available."
fi

if [[ ! -f ${PROM_DIR?}/prometheus ]]
then
    cd /tmp || exit
    wget -O /tmp/prometheus.tgz ${PROMETHEUS?} >/dev/null 2>&1
    tar -xzvf /tmp/prometheus.tgz >/dev/null 2>&1

    id -u prometheus >/dev/null 2>&1

    if [[ $? -ne 0 ]]
    then
        useradd prometheus -m -d ${PROM_DIR?}
    fi

    mv /tmp/prometheus-*/* ${PROM_DIR?}
    cp ${PROM_TMP_SRC_DIR?}/config/prometheus.yml ${PROM_DIR?}

    chown -R prometheus:prometheus ${PROM_DIR?}
    chmod 700 /var/lib/prometheus/

    cp ${PROM_TMP_SRC_DIR?}/config/prometheus.service /usr/lib/systemd/system
    chown root:root /usr/lib/systemd/system/prometheus.service
    chmod 644 /usr/lib/systemd/system/prometheus.service

    systemctl daemon-reload
    systemctl enable prometheus
    systemctl start prometheus
    systemctl status prometheus
fi

pwd
sleep 10
${PROM_TMP_SRC_DIR?}/scripts/nexus-setup.sh
${COMMON_DIR?}/scripts/node_exporter_install.sh

exit 0
