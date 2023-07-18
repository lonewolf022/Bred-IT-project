#!/bin/bash

. /home/svc_aiautomate/.bash_profile >> /dev/null

target_dir='/tmp/automate'
date=$(date +"%Y%m%d")
ydate=$(date +"%Y%m%d" -d "yesterday")

bank=$1

cd $target_dir

daily_file=$(ls -1t | grep "${bank}_account_output_D_${date}" | tail -1)
#weekly_file=$(ls -1t | grep "${bank}_account_output_W_${date}" | tail -1)
weekly_file=$(find ${target_dir} -name "${bank}_account_output_W_*" -mtime -1 | tail -1)
monthly_file=$(find ${target_dir} -name "${bank}_account_output_M_*" -mtime -1 | tail -1)
bvl_en_monthly_file=$(ls -1t | grep "${bank}_account_output_ENG_M_${date}" | tail -1)
bvl_fr_monthly_file=$(ls -1t | grep "${bank}_account_output_FR_M_${date}" | tail -1)


#echo $daily_file
#echo $weekly_file
#echo $monthly_file
#echo $bvl_en_monthly_file
#echo $bvl_fr_monthly_file

if [ $bank != "BVL" ]
 then
if [ -z "$daily_file" ]
 then
    echo " No $bank Daily Account list"
    echo "$bank Daily: 0" > /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
 else
    num_daily_acc=`cat $daily_file | sed '/^[[:space:]]*$/d' | grep -v "CUST_AC_NO" | wc -l`
    echo "$bank daily statement $num_daily_acc"
    echo "$bank Daily: $num_daily_acc" > /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
fi

if [ -z "$weekly_file" ]
 then
    echo " No $bank Weekly Account list"
    echo "$bank Weekly: 0" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
 else
    num_weekly_acc=`cat $weekly_file | sed '/^[[:space:]]*$/d' | grep -v "CUST_AC_NO" | wc -l`
    echo "$bank weekly statement $num_weekly_acc"
    echo "$bank Weekly: $num_weekly_acc" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
fi

if [ -z "$monthly_file" ]
 then
    echo " No $bank Monthly Account list"
    echo "$bank Monthly: 0" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
 else
    num_monthly_acc=`cat $monthly_file | sed '/^[[:space:]]*$/d' | grep -v "CUST_AC_NO" | wc -l`
    echo "$bank monthly statement $num_monthly_acc"
    echo "$bank Monthly: $num_monthly_acc" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
fi
else
if [ -z "$bvl_en_monthly_file" ]
  then
    if [ -z "$bvl_fr_monthly_file" ]
     then
       echo "No BVL Account list"
       echo "$bank Daily: 0" > /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
       echo "$bank Weekly: 0" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
       echo "$bank Monthly: 0" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
     else
      echo "NO BVL ENG"
     fi
   elif [ -z "$bvl_fr_monthly_file" ]
     then
       echo "NO BVL FRA"
       echo "$bank FRA Monthly: 0" > /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
    else
      num_en=`cat $bvl_en_monthly_file | sed '/^[[:space:]]*$/d' | grep -v "CUST_AC_NO" | wc -l`
      num_fr=`cat $bvl_fr_monthly_file | sed '/^[[:space:]]*$/d' | grep -v "CUST_AC_NO" | wc -l`
      echo "ENG: $num_en  FRA: $num_fr"
      num_bvl_acc=$((num_en + num_fr))
      echo "Total: $num_bvl_acc"
      echo "$bank Daily: 0" > /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
      echo "$bank Weekly: 0" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
      echo "$bank Monthly: $num_bvl_acc" >> /home/svc_aiautomate/${bank}_dwh_result_`date +"%Y%m%d"`.txt
     fi
    fi
