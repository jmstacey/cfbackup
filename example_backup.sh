#!/bin/sh

# Rename this file to cfbackup (no extension) if you are going to place in /etc/cron.daily

cd ~/cfbackup/temp
CONTAINER=jonsview_swift_backups
NOW=$(date +_%b_%d_%y)

# Dump all MySQL databases
mysqldump -u root -pPASSWORD --all-databases --flush-logs --lock-all-tables | gzip -9 > mysql_all_backup$NOW.sql.gz

# Create main backup archive
tar -czvf swift_backup$NOW.tar.gz /home/user1 /home/user2 /etc /usr/local/nginx

cd ~/cfbackup
ruby cfbackup.rb --local_path temp/ --container $CONTAINER
rm -f temp/*