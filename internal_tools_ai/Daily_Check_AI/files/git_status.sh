#!/bin/bash

path_file_td=`(find /var/lib/jenkins/workspace/DASHBOARD_GIT_AI/ -name  *$(date +"%Y%m%d")*.html)`
ignore_repo='DMM2|BVL_FlexcubeV14|BVL_Flexcubev14|BBF_BIP_REPORTS|BBF_OBIEE_RPD|BBF_CTRLM_FCC_APP|BBF_CTRLM_BIP_APP|BBF_CTRLM_FCC_DB|BBF_ORACLE_FCC_DB|BIPV12|BCIMR_CTRLM|BCIMR_ORACLE|BBF_ORACLE_DWH_DB|BBF_CTRLM_DWH_DB'

if [ -z "$path_file_td" ]
 then
     echo "<p>File not found,Please check DASHBOARD_GIT_AI job on jenkins.</br>"
     echo "<p>Dashboard GIT status:<span style="color:#F40C44">&nbsp;NOK&nbsp;</span></br>"
 else
     git_result=`less $path_file_td | grep -B 2 NOK | grep ^"<td style=width:20%" | awk -F">" '{ print $2 $4}' | sed 's/<\/td/  /g' |grep -Ev $ignore_repo | awk -F'  ' '{ print "<p>Repo Name: " $1 " Branch: " $2 " Status: NOK</br>"}'`
     #echo $git_result
     if [ -z "$git_result" ]
     then
       echo "<p>Dashboard GIT status:<span style="color:#05AD45">&nbsp;OK&nbsp;</span></br>"
     else
       echo -e "$git_result"
       echo "<p>Dashboard GIT status:<span style="color:#F40C44">&nbsp;NOK&nbsp;</span></br>"
     fi
fi
