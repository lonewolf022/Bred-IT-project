#!/bin/bash


grep -A 10000 `date +"%Y%m%d" -d "-1 day"` /var/log/sftp.log

sftp_error=$(less /var/log/sftp.log | grep -A 10000 `date +"%Y%m%d" -d "-1 day"` | grep -i -E 'error|timeout|failed|found' | wc -l)

echo "###########  Check SFTP ABNotes Log `date +"%Y-%m-%d" -d "-1 day"` ##########"
grep -A 8 -B 1 `date +"%Y-%m-%d" -d "-1 day"` /var/log/sftp-ABNotes.log

echo "###########  Check SFTP ABNotes Log `date +"%Y-%m-%d"` ##########"
grep -A 8 -B 1 `date +"%Y-%m-%d"` /var/log/sftp-ABNotes.log



if [[ "$sftp_error" -gt 0 ]];
 then
     echo "Please check SFTP log"
     sftp_status="SFTP NOK\nPlease escalate Saas-team immediately to check error SFTP log on  MBEBKKSFTPP01"
 else
     sftp_status="SFTP OK"
fi

host=`hostname | awk -F. '{print $1}'`
echo "\nCheck transfers to ABNotes : $sftp_status" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo -e "Check transfers to ABNotes : $sftp_status"
