#!/bin/sh
###############################################################################################################
# 
# Script Name     : wfss-chagecheck.sh                                                                                             
# Arguments       : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/20                                          
# Description     :                                                                                 
# This script is intended to look at the /etc/shadow file and get a list of users that have a valid password
# For each of those users, check the age of the password (via chage -l) and calculate the age of the password
# then dump out the age information to a log file that is the monitored for various values
#
# To resolve this trigger, resolve the passwords that are causing the trigger
# 
###############################################################################################################
# Explanation of the contents of the /etc/shadow file
#username=       Username, up to 8 characters. Case-sensitive, usually all lowercase. A direct match to the username in the /etc/passwd file.
#password=       Password, 13 character encrypted.
#                A blank entry (eg. ::) indicates a password is not required to log in
#                "*" entry (eg. :*:) indicates the account has been disabled.
#dayslastchange= The number of days (since January 1, 1970) since the password was last changed.
#daysnextchange= The number of days before password may be changed (0 indicates it may be changed at any time)
#daysmustchange= The number of days after which password must be changed (99999 indicates user can keep his or her password unchanged for many, many years)
#dayswarn=       The number of days to warn user of an expiring password (7 for a full week)
#daysafter=      The number of days after password expires that account is disabled
#dayssince=      The number of days since January 1, 1970 that an account has been disabled
#reserved=       A reserved field for possible future use
###############################################################################################################

NAMES=()
LOGFILE="/var/log/wfss.chagecheck.log"
INFODAYS=15
WARNINGDAYS=5
EXPIREDDAYS=0
LOGMESSAGE="NORMAL"

###############################################################################################################
#  extract the usernames from /etc/shadow where the password is defined
###############################################################################################################
while IFS='' read -r LINE || [[ -n "$LINE" ]]; do

   IFS=':' read -r USERNAME PASSWORD DAYSLASTCHANGE DAYSNEXTCHANGE DAYSMUSTCHANGE DAYSWARN DAYSAFTER DAYSSINCE RESERVED <<< "$LINE"
   if [ ${#PASSWORD} -gt 2 ]; then
      NAMES+=($USERNAME)
   fi

done < "/etc/shadow"

echo "" > $LOGFILE
chmod 644 $LOGFILE

###############################################################################################################
#  traverse the array of names that were found
###############################################################################################################
for NAME in "${NAMES[@]}"; do
   echo $NAME

###############################################################################################################
#  convert current date to seconds and find expiration date of user
###############################################################################################################
   CURRENTDATE=$(date +%s)
   echo "CURRENTDATE=$CURRENTDATE"
   CHAGELINE=$(chage -l $NAME | grep "Password expires")
   IFS=':' read -r CHAGETEXT CHAGEDATE <<< $CHAGELINE

   if [[ ! -z $CHAGEDATE ]]; then

###############################################################################################################
#  convert expiration date to seconds
###############################################################################################################
      echo "CHAGEDATE=$CHAGEDATE"
      if [[ $CHAGEDATE != " never" ]]; then
###############################################################################################################
#  find the remaining days for expiry
###############################################################################################################
         PASSDATE=$(date -d "$CHAGEDATE" "+%s")
         echo "PASSDATE=$PASSDATE"
         (( EXPIRE = $PASSDATE - $CURRENTDATE))
         echo "EXPIRE=$EXPIRE"

###############################################################################################################
#  convert remaining days from sec to days
###############################################################################################################
         (( EXPIREDAYS =  $EXPIRE / 86400 ))
         if [ $EXPIREDAYS -le 0 ]; then
            LOGMESSAGE="EXPIRED"
         elif [ $EXPIREDAYS -le $WARNINGDAYS ]; then
            LOGMESSAGE="WARNING"
         elif [ $EXPIREDAYS -le $INFODAYS ]; then
            LOGMESSAGE="INFO"
         else
            LOGMESSAGE="NORMAL"
         fi
         echo "$LOGMESSAGE:Password for $NAME will expire in $EXPIREDAYS days" >> $LOGFILE
      else
         echo "NORMAL:Password for $NAME does not expire" >> $LOGFILE
      fi
   fi
done