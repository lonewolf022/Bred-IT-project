#!/bin/bash

target_dir=$1
folder=$2
target=$3
dof=$4

path_file_ytd=`(find ${target_dir}/${folder} -name  *$(date --date="$dof days ago" +"%Y%m%d")*.gpg )`
path_file_td=`(find ${target_dir}/${folder} -name  *$(date +"%Y%m%d")*.gpg  )`

#echo "$path_file_ytd"
#echo "$path_file_td"

if [ -z "$path_file_ytd" ]
 then
     echo "Please check $target not exist"
     status_file="NOK\nNo need escalate Saas-team immediately will check on working hours, Please check on Bank's Holidays or not."
 else
     status_file="OK"
fi

file_ytd=`(find ${target_dir}/${folder} -name  *$(date --date="$dof days ago" +"%Y%m%d")*.gpg  | awk -F/ '{print $NF}'  )`
file_td=`(find ${target_dir}/${folder} -name  *$(date +"%Y%m%d")*.gpg | awk -F/ '{print $NF}' )`

#echo -e "\t\t$target BACKUP\n Yesterday Backup: $file_ytd\n Today Backup: $file_td\n Ratio size: $compare_size %\n $target Status: $status_file\n "
host=`hostname | awk -F. '{print $1}'`
echo "\t\t______ $target _____\n" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "Today file : $file_ytd\n "  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$target Status: $status_file\n" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo -e "$target Status: $status_file "
