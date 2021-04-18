#!/bin/bash
###############################################################################################################
# 
# Script Name	   : wca_corecheck.sh                                                                                             
# Arguments       : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/20                                          
# Description   :                                                                                 
# File runs as a cron job to check for the existence of any files generated from WCA core dump
# if file(s) found will create a new file in the /tmp directory with specific name.
# this is work around for Zabbix monitoring not being able to detect existence of files by wildcard
# therefore, this script will create a well known filename too be able too trigger an alert that the core dump
# took place

# To correct this issue, there are manual steps.  These are to be documented.  For now, we fire the
# alarm and get attention to the issue.

# To resolve this trigger, simply address the old directories (e.g. delete) and delete the file $ALARMFILE
# 
###############################################################################################################

DATE=$(date)
COREFILE="/home/esadmin/esdata/logs/core*"          #$DIRECTORY is the path to the directory to monitor
JAVACORE="/home/esadmin/esdata/logs/javacore*"      #$DIRECTORY is the path to the directory to monitor
HEAPDUMP="/home/esadmin/esdata/logs/heapdump*"      #$DIRECTORY is the path to the directory to monitor
ALARMFILE="/var/log/wfss.wcacore.alarm"             #$ALARMFILE is the file created when the condition is met

###############################################################################################################
#  check for existence of any of the core files
###############################################################################################################
file=($COREFILE)
if [ -e "${file[0]}" ]; then
        echo "$DATE $file found." >> $ALARMFILE
fi

file=($JAVACORE)
if [ -e "${file[0]}" ]; then
        echo "$DATE $file found." >> $ALARMFILE
fi

file=($HEAPDUMP)
if [ -e "${file[0]}" ]; then
        echo "$DATE $file found." >> $ALARMFILE
fi