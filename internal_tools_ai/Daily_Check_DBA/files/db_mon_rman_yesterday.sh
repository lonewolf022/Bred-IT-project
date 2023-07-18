#!/bin/bash

. /home/oracle/.bash_profile

TODAY_DATE=`date --date="1 days ago" +"%Y%m%d"`
DATE=`date -d "${TODAY_DATE}" +"%a"`
MONTH=`date -d "${TODAY_DATE}" +"%b_%y"`
host=$1
RMAN_DIR=$2


if [[ "$host" == "BVLPRD" ]]; then
   RMAN_LOG_FILE=${RMAN_DIR}/${MONTH}/${TODAY_DATE}/backup_${TODAY_DATE}.log
     list_rman=`ls -l ${RMAN_DIR}/${MONTH}/${TODAY_DATE} | grep -v total | grep -v backup | awk '{print "<p>       "$5" "$6" "$7" "$8" "$NF"</br>"}'`
elif [[ "$host" == "MBK_CADDB_PRD" ]]; then
   RMAN_LOG_FILE=${RMAN_DIR}/${TODAY_DATE}/backup_${TODAY_DATE}_0600.log
     list_rman=`ls -l ${RMAN_DIR}/${TODAY_DATE} | grep -v total | grep -v backup | awk '{print "<p>       "$5" "$6" "$7" "$8" "$NF"</br>"}'`
elif [[ "$host" == "BVL_CADDB_PRD" ]]; then
   RMAN_LOG_FILE=${RMAN_DIR}/${DATE}/backup_${TODAY_DATE}_12.log
   list_rman=`ls -l ${RMAN_DIR}/${DATE} | grep -v total | grep -v backup | awk '{print "<p>       "$5" "$6" "$7" "$8" "$NF"</br>"}'`
else
   RMAN_LOG_FILE=${RMAN_DIR}/${DATE}/${MONTH}/${TODAY_DATE}/backup_${TODAY_DATE}.log
     list_rman=`ls -l ${RMAN_DIR}/${DATE}/${MONTH}/${TODAY_DATE} | grep -v total | grep -v backup | awk '{print "<p>       "$5" "$6" "$7" "$8" "$NF"</br>"}'`
fi
 echo $RMAN_LOG_FILE

hostname=`hostname | awk -F. '{print $1}'`

if [ ! -f "$RMAN_LOG_FILE" ]
then
    echo " <p><span style="font-size:14px"><b>************** List rman backup ${host} on ${hostname} ******************</b></span></br>
     <p>`date`</br>

    <p><span style="font-size:14px"><b>Please call to DBA for check on ${hostname} !! No backup log ${TODAY_DATE}</b></span></br>
    <p><span style="font-size:14px"><b>********************************</b></span></br>" > /tmp/daily_check_rman_$host-`date +"%Y%m%d"`.log
else
    CHECK_R_STAT=`cat $RMAN_LOG_FILE |grep 'ORA-'`
    if [[ $CHECK_R_STAT -ne 0 ]]
    then
      rc=`expr $rc + 1`

      echo "
        <p><span style="font-size:14px"><b>************** List rman backup ${host} on ${hostname} ******************</b></span></br>
        <p>`date`</br>

        <p><b>---- List of backup -----</b></br>
        $list_rman

        <p><b>Job rman archive log backup on ${host} <span style="color:#F40C44">&nbsp;failed !!&nbsp;</span></b></br>
        <p><span style="font-size:14px"><b>Please call to DBA for check and create ticket!!, and then please place db backup status in daily monitor.</b></span></br>
        <p><span style="font-size:14px"><b>********************************</b></span></br> " > /tmp/daily_check_rman_$host-`date +"%Y%m%d"`.log
    else
      rc=0
       echo "
        <p><span style="font-size:14px"><b>************** List rman backup ${host} on ${hostname} ******************</b></span></br>
        <p>`date`</br>

        <p><b>---- List of backup -----</b></br>
        $list_rman

        <p><b>Job rman archive log backup on ${host} <span style="color:#05AD45">&nbsp;completed !!.&nbsp;</span></b></br>
        <p><span style="font-size:14px"><b>********************************</b></span></br>" > /tmp/daily_check_rman_$host-`date +"%Y%m%d"`.log
    fi
fi

echo "Check $host RMAN on $hostname done"
