#!/bin/bash

. /home/svc_aiautomate/.bash_profile >> /dev/null

TODAY=$(date +'%Y%m%d')

cd /home/svc_aiautomate
rm -f temp_dwh.txt
echo "
     <table>
     <tr><td>
     <style type="text/css">
        table.tableizer-table {
                font-size: 12px;
                border: 1px solid #CCC;
                font-family: Arial, Helvetica, sans-serif;
        }
        .tableizer-table td {
                padding: 4px;
                margin: 3px;
                border: 1px solid #CCC;
        }
        .tableizer-table th {
                background-color: #08345F;
                color: #FFF;
                font-weight: bold;
        }
                h2 {
                display: block;
                font-size: 1.0em;
                font-family: Arial, Helvetica, sans-serif;
                margin-top: 0.83em;
                margin-bottom: 0.83em;
                margin-left: 0;
                margin-right: 0;
                font-weight: bold;
        }

</style>
<h2 style="text-align:center"> Account list on DWH</h2>
<table class="tableizer-table">
<thead><tr class="tableizer-firstrow"><th>Bank</th><th>Daily</th><th>Weekly</th><th>Monthly</th></tr></thead><tbody>" > temp_dwh.txt

for value in BCIMR BBC BFL BBF BVL BBS
do
    D=$(cat summary_dwh_result_${TODAY}.txt | grep $value | awk '{print $3}' | head -1)
    W=$(cat summary_dwh_result_${TODAY}.txt | grep $value | awk '{print $3}' | head -2 | tail -1)
    M=$(cat summary_dwh_result_${TODAY}.txt | grep $value | awk '{print $3}' | head -3 | tail -1)
    D="${D:=0}"
    W="${W:=0}"
    M="${M:=0}"
    echo "<tr><td><b>$value</b></td><td>&nbsp;$D&nbsp;</td><td>&nbsp;$W&nbsp;</td><td>&nbsp;$M&nbsp;</td></tr>" >> temp_dwh.txt
done

echo "</tbody></table></td><td>&nbsp;&nbsp;</td><td>" >> temp_dwh.txt
