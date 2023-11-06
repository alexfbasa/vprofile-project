#!/bin/bash

USER='postgres'
GROUP='postgres'
PGSQL_VER='15'
PGSQL_SRC_DIR='/tmp/postgres'
PGSQL_DIR='/var/lib/pgsql'
COMMON_DIR='/tmp/common'
BIN_DIR="/usr/pgsql-${PGSQL_VER}/bin"
PGDG="https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm"

if curl --output /dev/null --silent --head --fail "$PGDG"; then
    echo "URL $PGDG available."
else
    echo "URL $PGDG not available."
fi

yum install -y ${PGDG} >/dev/null 2>&1

yum install -y postgresql15 \
               postgresql15-contrib \
               postgresql15-libs \
               postgresql15-server \
               postgresql15-docs \
               pgbackrest \
               >/dev/null 2>&1

/usr/pgsql-${PGSQL_VER}/bin/postgresql-15-setup initdb
systemctl enable postgresql-15

mkdir ${PGSQL_DIR}/.ssh

cp ${PGSQL_SRC_DIR}/config/pgbackrest.conf /etc/pgbackrest.conf
cp ${PGSQL_SRC_DIR}/config/authorized_keys ${PGSQL_DIR}/.ssh
cp ${PGSQL_SRC_DIR}/config/config ${PGSQL_DIR}/.ssh/config
cp ${PGSQL_SRC_DIR}/config/postgres ${PGSQL_DIR}/.ssh
cp ${PGSQL_SRC_DIR}/config/postgresql.conf ${PGSQL_DIR}/${PGSQL_VER}/data
cp ${PGSQL_SRC_DIR}/config/pg_hba.conf ${PGSQL_DIR}/${PGSQL_VER}/data

chown -R ${USER}:${GROUP} ${PGSQL_DIR}
chmod 700 ${PGSQL_DIR}/.ssh
chmod 600 ${PGSQL_DIR}/.ssh/config
chmod 600 ${PGSQL_DIR}/.ssh/authorized_keys
chmod 400 ${PGSQL_DIR}/.ssh/postgres
chmod 600 ${PGSQL_DIR}/${PGSQL_VER}/data/postgresql.conf
chmod 600 ${PGSQL_DIR}/${PGSQL_VER}/data/pg_hba.conf
restorecon ${PGSQL_DIR}/.ssh
restorecon ${PGSQL_DIR}/.ssh/config
restorecon ${PGSQL_DIR}/.ssh/authorized_keys

systemctl start postgresql-15

${COMMON_DIR?}/scripts/node_exporter_install.sh

${PGSQL_SRC_DIR?}/scripts/create_grafana_db_user.sh


su - postgres -c \
    "${BIN_DIR?}/psql -d postgres -f /tmp/postgres/scripts/statistics.sql"

${PGSQL_SRC_DIR?}/scripts/install_postgres_exporter.sh

exit 0
