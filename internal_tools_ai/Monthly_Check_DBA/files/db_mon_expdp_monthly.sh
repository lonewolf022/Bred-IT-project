#!/bin/bash

##################################
### Check monthly export on DWH
#################################

. /home/oracle/.bash_profile >> /dev/null


EXPDP_DIR=$2
TODAY_DATE=$(date +%Y%m)
#TODAY_DATE=20210602
DBNAME=$1
PREFIX_LOG=$3
DWH_MONTHLY_LOG=`ls -1 ${EXPDP_DIR} | grep ${PREFIX_LOG} | grep $TODAY_DATE | grep log`
#DWH_LOG_M_DATA=monthly_expdp_DWH_OBIEE_tables_${TODAY_DATE}_*.log
echo $DWH_MONTHLY_LOG
#DWH_LOG_M_DATA=monthly_expdp_DWH_OBIEE_tables_20210604_*.log_test_fail
#DWH_LOG_M_DATA=monthly_expdp_DWH_OBIEE_tables_20210604_*.log_test_completed
hostname=`hostname | awk -F. '{print $1}'`

### Backup date condition ###

case "${DBNAME}" in
    "BBCDWHPR")
    BACKUP_GEN_DATE="Backup log will appear on second day of the month"
    ;;
    "BBFDWHPR")
    BACKUP_GEN_DATE="Backup log will appear on fifth day of the month"
    ;;
    "BCIPRODW")
    BACKUP_GEN_DATE="Backup log will appear on second day of the month"
    ;;
    "BFLDWHPR")
    BACKUP_GEN_DATE="Backup log will appear on second day of the month"
    ;;
    "BVLPRODW")
    BACKUP_GEN_DATE="Backup log will appear on second day of the month"
    ;;
    *)
    BACKUP_GEN_DATE="DB Name is not in the list"
    ;;
esac

# --- --- --- #

cd ${EXPDP_DIR}

if [ ! -f "$DWH_MONTHLY_LOG" ]
then
   echo "
   <p><span style="font-size:14px"><b>************** List expdp monthly backup ${DBNAME} on ${hostname} ---> ${BACKUP_GEN_DATE} ******************</b></span></br>
   <p>`date`</br>
   <p><span style="font-size:14px"><b>Please call to DBA for check on ${hostname} !! No backup log ${TODAY_DATE}</b></span></br>
    <p><span style="font-size:14px"><b>********************************</b></span></br>" > /tmp/monthly_check_expdp_$DBNAME-`date +"%Y%m%d"`.log
else
    CHECK_EXP_STAT=`cat ${DWH_MONTHLY_LOG} |grep -i 'ORA-'| wc -l`
    RESULT_LOG=`less ${DWH_MONTHLY_LOG} | grep -i "Dump file set for" -A 10 -B 2 | sed 's/^/\<p>/' | sed 's/$/<\/br>/'`
        if [[ $CHECK_EXP_STAT -ne 0 ]]
        then
                rc=`expr $rc + 1`
                echo "Job ${DBNAME} monthly export failed on $hostname"
                echo "
                <p><span style="font-size:14px"><b>************** List expdp monthly backup ${DBNAME} on ${hostname} ---> ${BACKUP_GEN_DATE}  ******************</b></span></br>
                <p>`date`</br>
                $RESULT_LOG
                <p><b>Job ${DBNAME} monthly export <span style="color:#F40C44">&nbsp;failed !!&nbsp;</span> on $hostname </b></br>
                <p><span style="font-size:14px"><b>********************************</b></span></br>" > /tmp/monthly_check_expdp_$DBNAME-`date +"%Y%m%d"`.log
        else
               rc=0
               echo "Job ${DBNAME} monthly export completed on $hostname"
               echo "
               <p><span style="font-size:14px"><b>************** List expdp monthly backup ${DBNAME} on ${hostname} ---> ${BACKUP_GEN_DATE}  ******************</b></span></br>
               <p>`date`</br>
               $RESULT_LOG
               <p><b> Job ${DBNAME} monthly export <span style="color:#05AD45">&nbsp;completed !!&nbsp;</span> on $hostname </b></br>
               <p><span style="font-size:14px"><b>********************************</b></span></br>" > /tmp/monthly_check_expdp_$DBNAME-`date +"%Y%m%d"`.log
        fi
fi
