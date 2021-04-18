#!/bin/sh
###############################################################################################################
# 
# Script Name     : wca_articlecheck.sh                                                                                             
# Args            : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/20                                          
# Description     :                                                                                 
# This script is intended to look for the age of directories with the target directory ($DIRECTORY)
# In Watson Content Analytics (WCA) there are directories on the file system that are consumed for
# various processing, if for some reason the processing fails, the directory is left behind.  Once
# these directories are left behind or orphaned this can cause additional isses for WCA.  This script
# will check for directories that are older than the $ARTICLE_AGE in minutes.  Once that threshold is
# passed, a file is created in the $ALARMFILE path and Zabbix monitoring will fire a trigger.

# To correct this issue, there are manual steps.  These are to be documented.  For now, we fire the
# alarm and get attention to the issue.

# To remediate this trigger, simply address the old directories (e.g. delete) and delete the file $ALARMFILE
# 
###############################################################################################################

DATE=$(date)
DIRECTORY="/data/CKYC/WCA/WCA_Article/Unprocessed"  #$DIRECTORY is the path to the dirtory to monitor
ALARMFILE="/var/log/wfss.wcaarticles.alarm"         #$ALARMFILE is the file created when the contidion is met
MAXFILESIZE=100000                                  #$MAXFILESIZE is the max size of the log file before rollover
ARTICLE_AGE=30                                      #$ARTICLE_AGE is the number of minutes to check age of directory

echo "checking $DIRECTORY"
for d in $DIRECTORY/* ; do
   if [ -d "$d" ]; then
      AGE=`find "$d" -maxdepth 0 -mmin +$ARTICLE_AGE`
      if [ $AGE ]; then
         echo "$d - IS older than $ARTICLE_AGE mins"
         if [ ! -f $ALARMFILE ]; then
            echo "$DATE" >> $ALARMFILE
            echo "$date $d IS older than $ARTICLE_AGE mins" >> $ALARMFILE
         fi
      else
         echo "$d - IS NOT older than $ARTICLE_AGE mins"
      fi
   else
      if [ -f $ALARMFILE ]; then
         rm $ALARMFILE
      fi
   fi
done

#######################################################
#  check to see if the alarmfile needs to be rolled over
#######################################################
if [ -f $ALARMFILE ]; then
   FILESIZE=$(stat -c%s "$ALARMFILE")
   echo "$ALARMFILE size = $FILESIZE"
   if [ $FILESIZE -gt $MAXFILESIZE ]; then
      echo "$ALARMFILE needs to move"
      mv "$ALARMFILE" "$ALARMFILE.bkup"
      echo "" > $ALARMFILE
   fi
fi