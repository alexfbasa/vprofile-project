#!/bin/bash
# Create Bidirectional SSH Keys for pgBackrest and Postgres

set -u

PGSQL='./services/postgres/config'
BACKREST='./services/pgbackrest/config'
LOG_FILE='setup.log'  # Define a log file

# Function to log output and errors
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

log "Starting the setup.sh script..."

if [[ -f ${PGSQL?}/postgres ]]
then
    rm -f ${PGSQL?}/postgres
    rm -f ${PGSQL?}/postgres.pub
fi

if [[ -f ${BACKREST?}/backrest ]]
then
    rm -f ${BACKREST?}/backrest
    rm -f ${BACKREST?}/backrest.pub
fi

ssh-keygen -b 2048 -t rsa -f ${PGSQL?}/postgres -q -N "" 2>&1 | log "Creating SSH key for Postgres"
ssh-keygen -b 2048 -t rsa -f ${BACKREST?}/backrest -q -N "" 2>&1 | log "Creating SSH key for pgBackrest"

cat ${PGSQL?}/postgres.pub > ${BACKREST?}/authorized_keys 2>&1 | log "Copying Postgres public key to pgBackrest"
cat ${BACKREST?}/backrest.pub > ${PGSQL?}/authorized_keys 2>&1 | log "Copying pgBackrest public key to Postgres"

log "Configuration completed successfully."

# Display the contents of the log file at the end
echo "Contents of $LOG_FILE:"
cat "$LOG_FILE"
