#!/bin/bash

. /home/svc_aiautomate/.bash_profile >> /dev/null

target_dir=$1
folder=$2
target=$3

path_file_ytd=$(find ${target_dir}/${folder} -name  *$(date --date=' 2 days ago' +"%Y%m%d")* )
path_file_td=$(find ${target_dir}/${folder} -name  *$(date --date=' 1 days ago' +"%Y%m%d")* )


echo "$path_file_ytd"
echo "$path_file_td"
#### Move tmp file #####



if [ -z "$path_file_ytd" ]
 then
      echo "Please check $target backup yesterday"
      status_file="YESTERDAY BACKUP NOT EXIST NOK\nNo need escalate Saas-team immediately will check on working hours, Please check on Bank's Holidays or not."
      ytd_size=0
 else
     if [ -z "$path_file_td" ]
        then
            echo "Please check $target backup today"
            status_file="TODAY BACKUP NOT EXIST NOK\nNo need escalate Saas-team immediately will check on working hours, Please check on Bank's Holidays or not."
            td_size=0
        else
            ytd_size=$(find $path_file_ytd -printf "%s")
            td_size=$(find $path_file_td -printf "%s")
            echo $ytd_size
            echo $td_size
            #compare_size=$((($ytd_size/$td_size)*100))
            #compare_size=$(bc <<< "scale=2; ($ytd_size/$td_size) * 100")
            compare_size=$(bc <<< "scale=2; ($td_size/$ytd_size) * 100")
#            echo "$compare_size %"
            if [[ $(printf "%.f" "$compare_size") -lt 80 ]];
               then
                   status_file="SIZE NOK\nNo need escalate Saas-team immediately will check on working hours. "
               else
                   status_file="OK"
            fi
     fi
fi

file_ytd=$(find ${target_dir}/${folder} -name  *$(date --date=' 2 days ago' +"%Y%m%d")* | awk -F/ '{print $NF}')
file_td=$(find ${target_dir}/${folder} -name  *$(date --date=' 1 days ago' +"%Y%m%d")* | awk -F/ '{print $NF}')



ytd_size_kb=$((ytd_size / 1024))
td_size_kb=$((td_size / 1024))

host=$(hostname | awk -F. '{print $1}')
#echo -e "\t\t$target BACKUP\n Yesterday Backup: $file_ytd\n Today Backup: $file_td\n Ratio size: $compare_size %\n $target Status: $status_file\n "
echo "\t\t______ $target _____\n" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "Yesterday file: $file_ytd size: $ytd_size_kb KB\n"  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "Today file: $file_td size: $td_size_kb KB\n" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo "$target Status: $status_file\n\n" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo -e "$target Status: $status_file "
