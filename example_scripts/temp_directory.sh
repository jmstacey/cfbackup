#!/bin/sh

# temp_directory.sh
#
# This script demonstrates how CFBackup could be used to peform
# automated backups. In this example, backups are first created 
# and placed in a temporary holding directory. Then, the entire 
# directory is uploaded to Cloud Files. Finally, the temp directory 
# is cleared in preparation for the next scheduled backup.
#
# Modify it to suit your needs.

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