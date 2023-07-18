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
     status_file="<p>$target Status: <span style="color:#F4A70C">&nbspNOK&nbsp</span></br><p>No need escalate Saas-team immediately will check on working hours.</span></br>"
 else
     status_file="<p>$target Status: <span style="color:#05AD45">&nbsp;OK&nbsp;</span></br>"
fi

file_ytd=`(find ${target_dir}/${folder} -name  *$(date --date="$dof days ago" +"%Y%m%d")*.gpg  | awk -F/ '{print $NF}'  )`
file_td=`(find ${target_dir}/${folder} -name  *$(date +"%Y%m%d")*.gpg | awk -F/ '{print $NF}' )`

#echo -e "\t\t$target BACKUP\n Yesterday Backup: $file_ytd\n Today Backup: $file_td\n Ratio size: $compare_size %\n $target Status: $status_file\n "
host=`hostname | awk -F. '{print $1}'`
echo "<p><strong>______ $target _____</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>Today file : $file_ytd</br> "  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$status_file" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$status_file "
