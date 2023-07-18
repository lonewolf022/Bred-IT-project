#!/bin/bash


source /home/oracle/.bash_profile > /dev/null


USER=$2
PASS=$3
WORKDIR="/home/oracle/Scripts/bin"
TODAY=$(date +%Y%m%d%H%M)

export ORACLE_SID=$1

cd $WORKDIR
echo "Reseting password for $USER ... "

${ORACLE_HOME}/bin/sqlplus -s '/  as sysdba ' << EOF
set verify off
set echo off

alter user $USER identified by "$PASS" account unlock;

exit
EOF
