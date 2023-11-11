#!/bin/bash
# Define variables
SONAR_USER="sonar_user"
SONAR_USER_PASSWORD="snrqb_pas7dsw0rd30"
SONAR_DB="sonar_db"

psql -U postgres -c "CREATE USER $SONAR_USER WITH ENCRYPTED PASSWORD '$SONAR_USER_PASSWORD';"
psql -U postgres -c "CREATE DATABASE $SONAR_DB OWNER $SONAR_USER;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $SONAR_DB TO $SONAR_USER;"

exit 0
