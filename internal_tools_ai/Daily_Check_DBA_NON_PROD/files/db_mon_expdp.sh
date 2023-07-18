#!/bin/bash

##################################
### Check monthly export on DWH
#################################

. /home/oracle/.bash_profile >> /dev/null


EXPDP_DIR=$2
TODAY_DATE=$(date +%Y%m%d)
#TODAY_DATE=20210602
DBNAME=$1
PREFIX_LOG=$3
DWH_MONTHLY_LOG=`ls -1 ${EXPDP_DIR} | grep ${PREFIX_LOG} | grep $TODAY_DATE | grep log`
DWH_LOG_M_DATA=monthly_expdp_DWH_OBIEE_tables_${TODAY_DATE}_*.log
echo $DWH_MONTHLY_LOG
#DWH_LOG_M_DATA=monthly_expdp_DWH_OBIEE_tables_20210604_*.log_test_fail
#DWH_LOG_M_DATA=monthly_expdp_DWH_OBIEE_tables_20210604_*.log_test_completed
hostname=`hostname | awk -F. '{print $1}'`


cd ${EXPDP_DIR}

if [ ! -f "$DWH_MONTHLY_LOG" ]
then
   echo "
   ************** List expdp monthly backup ${DBNAME} on ${hostname} ******************
   `date`
   Please call to DBA for check on ${hostname} !! No backup log ${TODAY_DATE} " > /tmp/monthly_check_expdp_$DBNAME-`date +"%Y%m%d"`.log
else
    CHECK_EXP_STAT=`cat ${DWH_MONTHLY_LOG} |grep -i 'ORA-'| wc -l`
    RESULT_LOG=`grep -i "Dump file set for" -A 10 -B 3 ${DWH_MONTHLY_LOG}`
        if [[ $CHECK_EXP_STAT -ne 0 ]]
        then
                rc=`expr $rc + 1`
                echo "Job ${DBNAME} monthly export failed on $hostname"
                echo "
                ************** List expdp monthly backup ${DBNAME} on ${hostname} ******************
                `date`
                $RESULT_LOG
                Job ${DBNAME} monthly export failed on $hostname" > /tmp/monthly_check_expdp_$DBNAME-`date +"%Y%m%d"`.log
        else
               rc=0
               echo "Job ${DBNAME} monthly export completed on $hostname"
               echo "
               ************** List expdp monthly backup ${DBNAME} on ${hostname} ******************
               `date`
               $RESULT_LOG
               Job ${DBNAME} monthly export completed on $hostname" > /tmp/monthly_check_expdp_$DBNAME-`date +"%Y%m%d"`.log
        fi
fi
