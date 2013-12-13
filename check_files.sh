#!/usr/bin/env bash

# This script will count file on remote server
# if file count is greater than threshold value
# then it will trigger email


# Prequirement 
# - Set password less authentication
# - tools - find,ssh,wc

max_files_count=5000
email_addr=admin@localhost
location=/opt/
remote_server=127.0.0.1
remote_user=rahul

count_files=$( ssh ${remote_user}@${remote_server} "find $location -type f | wc -l" )

if [[ $count_files -gt $max_files_count ]];
then
	echo "File count limite is cross :: $count_files" | \
	mail -s "File Count Status of $remote_server" $email_addr
else
	echo "File count is OK: $count_files"
fi
