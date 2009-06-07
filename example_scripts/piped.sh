#!/bin/sh

# piped.sh
#
# This script demonstrates how CFBackup could be used to peform
# automated backups. In this example, data is piped directly
# to a Cloud Files container, bypassing the need for a temporary
# holding directory.
#
# Modify it to suit your needs.

CONTAINER=backups
NOW=$(date +_%b_%d_%y)

# Backup all MySQL databases
mysqldump -u root -pPASSWORD --all-databases --flush-logs --lock-all-tables | gzip -9 | cfbackup --action push --pipe_data --container $CONTAINER:mysql_all_backup$NOW.sql.gz

# Create main backup archive
tar -cvf - /home/user /etc /usr/local/nginx | gzip -9 | cfbackup --action push --pipe_data --container $CONTAINER:main_backup$NOW.tar.gz