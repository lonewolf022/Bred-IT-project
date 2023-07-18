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

echo "Host Unavailable: $Unavailable"
echo "Today $TD Job NOK: $td_job_nok"
echo "Yesterday $YTD Job NOK: $ytd_job_nok"
host=`hostname | awk -F. '{print $1}'`

if [[ $Unavailable -eq 0  ]] ;
  then
       host_status="<p> $host Control-M Agent Status: <span style="color:#05AD45">&nbsp;OK&nbsp;</span></br>"
  else
       echo "Please check hosts status"
       host_status="<p> $host Control-M Agent Status: <span style="color:#F40C44">&nbsp;NOK&nbsp;</span></br><p>Please escalate Saas-team immediately to check control-m agent</br>"
fi

if [[ $td_job_nok -eq 0 && $ytd_job_nok -eq 0 ]] ;
  then
       job_status="<p> $host Control-M Job Status: <span style="color:#05AD45">&nbsp;OK&nbsp;</span></br>"
  else
#       if [[ $td_job_nok -gt 0 || $ytd_job_nok -gt 0 ]];
#       then
       echo "Please check control-m job status"
       job_status="<p> $host Control-M Job Status: <span style="color:#F40C44">&nbsp;NOK&nbsp;</span></br><p>Please check on control-m selfservice and alert mail which define need standby or not</br>"
#       fi
fi

echo "<p><strong>############# List Control-M Agent Unavailable ${TD} on $host ###########</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
ctm_agstat -LIST "*" | grep "Unavailable" | sed 's/^Agent/\<p>Agent/' | sed 's/Unavailable/Unavailable<\/br>/' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo -en '\n\n' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p><strong>###############  DAILY JOB NOTOK ${TD} on $host ##############</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>ORDERID  JOBNAME           TYPE  ODATE    STATUS   COMPSTATE RUNCNT</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>-------- ----------------- ----  -------- ------ ----------- ------</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

## check job notok on TODAY
ctmpsm -LISTJOB NOTOK | grep "$TD" | grep -e ^000 | sed 's/^000/\<p>000/' | sed 's/$/\<\/br>/' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo -en '\n\n' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p><strong>###############  DAILY JOB NOTOK ${YTD} on $host ##############</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>ORDERID  JOBNAME           TYPE  ODATE    STATUS   COMPSTATE RUNCNT</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>-------- ----------------- ----  -------- ------ ----------- ------</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

## check job notok on YESTERDAY
ctmpsm -LISTJOB NOTOK | grep "$YTD" | grep -e ^000 | sed 's/^000/\<p>000/' | sed 's/$/\<\/br>/' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log

echo "<p>Host Unavailable: $Unavailable</br>"  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>Today $TD Job NOK: $td_job_nok</br>"  >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "<p>Yesterday $YTD Job NOK: $ytd_job_nok</br>" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$host_status" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "$job_status" >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo -en '\n\n' >> /tmp/daily_check_$host-`date +"%Y%m%d"`.log
echo "Control-m Job Status $TD"
echo "Control-M Agent Status: $host_status"
echo "Control-M Job Status: $job_status"
