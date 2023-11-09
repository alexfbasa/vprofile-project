#!/bin/bash

set -e -u

GRAFANA_RPM='https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.0-1.x86_64.rpm'
GRAF_DIR='/usr/sbin'
GRAF_TMP_SRC_DIR='/tmp/grafana'
ZABX_TMP_SRC_DIR='/tmp/zabbix'

ZABBIX_REPO='https://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/zabbix-release-6.0-4.el8.noarch.rpm'



if [[ ! -f ${GRAF_DIR?}/grafana-server ]]; then
    yum install -y $GRAFANA_RPM >/dev/null 2>&1
    yum install -y fontconfig freetype* urw-fonts >/dev/null 2>&1
fi


rpm -Uvh $ZABBIX_REPO
dnf clean all
dnf -y module switch-to php:7.4
dnf -y install zabbix-server-pgsql zabbix-web-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

cp ${GRAF_TMP_SRC_DIR?}/config/zabbix_server.conf /etc/zabbix/zabbix_server.conf
cp ${GRAF_TMP_SRC_DIR?}/config/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php
cp ${GRAF_TMP_SRC_DIR?}/config/zabbix.conf /etc/nginx/conf.d/zabbix.conf
chmod 644 /etc/nginx/conf.d/zabbix.conf


cp ${GRAF_TMP_SRC_DIR?}/config/grafana.ini /etc/grafana/grafana.ini
chown root:grafana /etc/grafana/grafana.ini
chmod 640 /etc/grafana/grafana.ini

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server

systemctl stop zabbix-server zabbix-agent nginx php-fpm
systemctl enable zabbix-server zabbix-agent nginx php-fpm
systemctl start zabbix-server zabbix-agent nginx php-fpm &

exit 0
