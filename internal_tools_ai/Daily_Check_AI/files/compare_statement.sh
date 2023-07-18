#!/bin/bash

. /home/svc_aiautomate/.bash_profile

date=$(date +'%Y%m%d')
result_edm=/home/svc_aiautomate/temp_edm_${date}.txt
result_dwh=/home/svc_aiautomate/summary_dwh_result_${date}.txt


while IFS= read -r line1 && IFS= read -r line2 <&3; do
  head=`echo $line1 | awk '{ print $1 " " $2}'`
  dwh=`echo $line1 | awk '{ print $3}' | bc`
  edm=`echo $line2 | awk '{ print $3}'| bc`
  dwh="${dwh:=0}"
  edm="${edm:=0}"
  if [[ $dwh == $edm ]]
  then
   echo "$head $dwh == $edm OK"
   echo "<p>$head : <span style="color:#05AD45">&nbsp;OK&nbsp;</span></br>" >> /home/svc_aiautomate/temp_dwh.txt
  else
   echo "$head $dwh != $edm NOK"
   echo "<p>$head : <span style="color:#F4A70C">&nbsp;NOK&nbsp;</span></br>" >> /home/svc_aiautomate/temp_dwh.txt
  fi
#  echo "$line1 : $line2"
done < $result_dwh 3< $result_edm
