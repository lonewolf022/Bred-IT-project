#!/bin/bash

. /home/svc_aiautomate/.bash_profile >> /dev/null

TODAY=$(date --date=' 1 days ago' +'%d-%m-%Y')
#TODAY=31-08-2021
DATE=$(date +'%d-%m-%Y')


cd /home/svc_aiautomate

rm -f report_edm_*.txt

echo $TODAY
for type in D W M
do
# Login
curl --max-redirs 3 -c cookies.txt -L 'http://spedmcambkcslp1.bred-it-prod.ad.production.local:8080/otdsws/login' -X POST -H 'Content-Type: application/x-www-form-urlencoded' -H 'Referer: "http://spedmcambkcslp1.bred-it-prod.ad.production.local/OTCS/cs.exe?func=ll&objId=4212227&objAction=runReport&debugSQL=false&nextURL=%2FOTCS%2Fcs.exe%3Ffunc%3DPersonal.Reports%26objid%3D0%26mode%3DSHOW%26tab%3D3%26sort%3Dname%26action%3D%26ntabs%3D3&inputlabel1=${TODAY}&inputlabel2=${type}' --data-binary 'otdsauth=no-sso&otds_username=svc_edm&otds_password=Vy3tySpNYczeky5ZJK5P'

# and save page to "click on Continue" in form.txt
curl -b cookies.txt -L "http://spedmcambkcslp1.bred-it-prod.ad.production.local/OTCS/cs.exe?func=ll&objId=4212227&objAction=runReport&debugSQL=false&nextURL=%2FOTCS%2Fcs.exe%3Ffunc%3DPersonal.Reports%26objid%3D0%26mode%3DSHOW%26tab%3D3%26sort%3Dname%26action%3D%26ntabs%3D3&inputlabel1=${TODAY}&inputlabel2=${type}" > form.txt

# Extract fields from form.txt and create one file per each with the data
grep -Po 'name="\K.*?(?=")|value="\K.*?(?=")' form.txt | xargs -r -n2 sh -c 'echo "$1" > $0.data'

# Submit the form and get the report
curl -b cookies.txt -H "Referer: http://spedmcambkcslp1.bred-it-prod.ad.production.local:8080/otdsws/login" -L "http://spedmcambkcslp1.bred-it-prod.ad.production.local/OTCS/cs.exe" --data-urlencode OTDSTicket@OTDSTicket.data --data-urlencode redirectURL@redirectURL.data --data-urlencode func@func.data --data-urlencode NextURL@NextURL.data > report_edm_${type}_${DATE}.txt

#Cleanup intermediate file
rm cookies.txt
rm form.txt
rm ./*.data
done
