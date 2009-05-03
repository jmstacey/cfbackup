#!/bin/sh

# In this example, backups are first created and placed in a temporary
# holding directory. Then, the entire directory is uploaded to 
# Cloud Files. Finally, the temp directory is cleared in preparation
# for the next backup.
#
# This is an example script that you could use in combination with CFBackup.
# Modify it to suit your needs. Rename to file without an extension if you
# are going to place in /etc/cron.daily.

cd ~/cfbackup/temp
CONTAINER=backups
NOW=$(date +_%b_%d_%y)

# Dump all MySQL databases
mysqldump -u root -pPASSWORD --all-databases --flush-logs --lock-all-tables | gzip -9 > mysql_all_backup$NOW.sql.gz

# Create main backup archive
tar -czvf main_backup$NOW.tar.gz /home/user /etc /usr/local/nginx

cd ~/cfbackup
cfbackup --action push --local_path temp/ --container $CONTAINER
rm -f temp/*