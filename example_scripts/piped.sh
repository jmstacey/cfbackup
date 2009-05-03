#!/bin/sh

# In this example, data is piped direcly from the backup to a Cloud Files
# container, bypassing the intermediate temp directory step
#
# This is an example script that you could use in combination with CFBackup.
# Modify it to suit your needs. Rename to file without an extension if you
# are going to place in /etc/cron.daily.

cd ~/cfbackup
CONTAINER=backups
NOW=$(date +_%b_%d_%y)

# Backup all MySQL databases
mysqldump -u root -pPASSWORD --all-databases --flush-logs --lock-all-tables | gzip -9 | cfbackup.rb --action push --pipe_data --container $CONTAINER:mysql_all_backup$NOW.sql.gz

# Create main backup archive
tar -cvf - /home/user /etc /usr/local/nginx | gzip -9 | cfbackup.rb --action push --pipe_data --container $CONTAINER:main_backup$NOW.tar.gz