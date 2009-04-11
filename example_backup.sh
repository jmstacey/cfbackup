#!/bin/sh

# This is an example script that you could use in combination with CFBackup.
# Modify it to suit your needs. Rename to "cfbackup" (without an extension)
# if you are going to place in /etc/cron.daily.

cd ~/cfbackup/temp
CONTAINER=backups
NOW=$(date +_%b_%d_%y)

# Dump all MySQL databases
mysqldump -u root -pPASSWORD --all-databases --flush-logs --lock-all-tables | gzip -9 > mysql_all_backup$NOW.sql.gz

# Create main backup archive
tar -czvf swift_backup$NOW.tar.gz /home/user1 /home/user2 /etc /usr/local/nginx

cd ~/cfbackup
ruby cfbackup.rb --local_path temp/ --container $CONTAINER
rm -f temp/*