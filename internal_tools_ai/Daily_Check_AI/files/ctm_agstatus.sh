#!/bin/bash

#source /home/ctrlm/.profile

HOME_CTM=/home/ctrlm
cd $HOME_CTM
TD=`date +"%Y%m%d"`
YTD=`date +"%Y%m%d" -d "-1 day"`


echo "############# List Control-M Agent Unavailable ${TD} ###########"
ctm_agstat -LIST "*" | grep "Unavailable"

echo -en '\n\n'
echo "###############  DAILY JOB NOTOK ${TD}  ##############"
echo "ORDERID  JOBNAME           TYPE  ODATE    STATUS   COMPSTATE RUNCNT"
echo "-------- ----------------- ----  -------- ------ ----------- ------"

## check job notok on TODAY
ctmpsm -LISTJOB NOTOK | grep "$TD"

echo -en '\n\n'
echo "###############  DAILY JOB NOTOK ${YTD}  ##############"
echo "ORDERID  JOBNAME           TYPE  ODATE    STATUS   COMPSTATE RUNCNT"
echo "-------- ----------------- ----  -------- ------ ----------- ------"

## check job notok on YESTERDAY
ctmpsm -LISTJOB NOTOK | grep "$YTD"

Unavailable=`ctm_agstat -LIST "*" | grep "Unavailable" | wc -l`
td_job_nok=`ctmpsm -LISTJOB NOTOK | grep "$TD" | wc -l`
ytd_job_nok=`ctmpsm -LISTJOB NOTOK | grep "$YTD" | wc -l`

echo -e "Host Unavailable: $Unavailable\n Today $TD Job NOK: $td_job_nok\n Yesterday $YTD Job NOK: $ytd_job_nok\n"


if [[ $Unavailable -eq 0  ]] ;
  then
       host_status="OK"
  else
       echo "Please check hosts status"
       host_status="NOK\n Please escalate Saas-team immediately to check control-m agent"
fi

if [[ $td_job_nok -eq 0 && $ytd_job_nok -eq 0 ]] ;
  then
       job_status="OK"
  else
#       if [[ $td_job_nok -gt 0 || $ytd_job_nok -gt 0 ]];
#       then
       echo "Please check control-m job status"
       job_status="NOK\nPlease check on control-m selfservice and alert mail which define need standby or not "
#       fi
fi

host=`hostname | awk -F. '{print $1}'`

echo "############# List Control-M Agent Unavailable ${TD} on $host ###########" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
ctm_agstat -LIST "*" | grep "Unavailable" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo -en '\n\n' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "###############  DAILY JOB NOTOK ${TD} on $host ##############" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "ORDERID  JOBNAME           TYPE  ODATE    STATUS   COMPSTATE RUNCNT" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "-------- ----------------- ----  -------- ------ ----------- ------" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

## check job notok on TODAY
ctmpsm -LISTJOB NOTOK | grep "$TD" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo -en '\n\n' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "###############  DAILY JOB NOTOK ${YTD} on $host ##############" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "ORDERID  JOBNAME           TYPE  ODATE    STATUS   COMPSTATE RUNCNT" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "-------- ----------------- ----  -------- ------ ----------- ------" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

## check job notok on YESTERDAY
ctmpsm -LISTJOB NOTOK | grep "$YTD" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo "Host Unavailable: $Unavailable"  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "Today $TD Job NOK: $td_job_nok"  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "Yesterday $YTD Job NOK: $ytd_job_nok" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$host Control-M Agent Status: $host_status" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$host Control-M Job Status: $job_status" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo -en '\n\n' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo -e "\t\tControl-m Job Status $TD\n Control-M Agent Status: $host_status\n Control-M Job Status: $job_status"
