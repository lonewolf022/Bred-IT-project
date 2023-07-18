#!/bin/bash

. /home/svc_aiautomate/.bash_profile >> /dev/null

TODAY=$(date +'%d-%m-%Y')
TD=$(date +'%Y%m%d')
PERIOD=$1


cd /home/svc_aiautomate

rm -f temp_edm_*.txt

echo "
<h2 style="text-align:center">Number of Documents on EDM </h2>
<table class="tableizer-table">
<thead><tr class="tableizer-firstrow"><th>Bank</th><th>Daily</th><th>Weekly</th><th>Monthly</th></tr></thead><tbody>" >> temp_dwh.txt


for value in BCIMR BBC BFL BBF BVL BBS
do
  for time in D W M
  do
    count=$(grep -zPo "$value.*\n.*nbsp;\K\d+" report_edm_${time}_${TODAY}.txt)
    echo "$value : $count" >> temp_edm_${TD}.txt
  done
done


for value in BCIMR BBC BFL BBF BVL BBS
do
    D=$(cat temp_edm_${TD}.txt | grep $value | awk '{print $3}' | head -1)
    W=$(cat temp_edm_${TD}.txt | grep $value | awk '{print $3}' | head -2 | tail -1)
    M=$(cat temp_edm_${TD}.txt | grep $value | awk '{print $3}' | head -3 | tail -1)
    D="${D:=0}"
    W="${W:=0}"
    M="${M:=0}"
    echo "<tr><td><b>$value</b></td><td>&nbsp;$D&nbsp;</td><td>&nbsp;$W&nbsp;</td><td>&nbsp;$M&nbsp;</td></tr>" >> temp_dwh.txt
done

echo "
      </tbody></table>
      </td>
      </tbody></table>" >> temp_dwh.txt
