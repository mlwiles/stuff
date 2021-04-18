#!/bin/sh
###############################################################################################################
# 
# Script Name     : wfss-kubenodecheck.sh                                                                                             
# Args            : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/25                                         
# Description     :                                                                                 
# This script is intended to look at the status of the kubernetes nodes.  It will report back the status
# if anything other Ready. 

#                    Reference -        https://kubernetes.io/docs/concepts/architecture/nodes/#node-status
# OutOfDisk           True if there is insufficient free space on the node for adding new pods, otherwise False
# Ready               True if the node is healthy and ready to accept pods, False if the node is not healthy and is not accepting pods, 
#                     and Unknown if the node controller has not heard from the node in the last node-monitor-grace-period (default is 40 seconds)
# MemoryPressure      True if pressure exists on the node memory – that is, if the node memory is low; otherwise False
# PIDPressure         True if pressure exists on the processes – that is, if there are too many processes on the node; otherwise False
# DiskPressure        True if pressure exists on the disk size – that is, if the disk capacity is low; otherwise False
# NetworkUnavailable  True if the network for the node is not correctly configured, otherwise False

# To correct this issue, there are manual steps.  Situation will dictate on how to remediate the pod status

# To remediate this trigger, simply address the old directories (e.g. delete) and delete the file $ALARMFILE
# 
###############################################################################################################

TEMPFILE="/var/log/wfss.kubenodecheck.tmp"
ALARMFILE="/var/log/wfss.kubenodecheck.alarm"
ALARM=0

kubectl get nodes > $TEMPFILE
if [ -e $ALARMFILE ]; then
   echo "" > $ALARMFILE
fi

while IFS='' read -r KUBE || [[ -n "$KUBE" ]]; do

   IFS=' ' read -r NAME STATUS ROLES AGE VERSION <<< "$KUBE"

   if [ $NAME != "NAME" ]; then
      if [ $STATUS != "Ready" ]; then
         echo ${STATUS^^}:$NAME >> $ALARMFILE
         ALARM=1
      fi
   fi

   if [ ALARM = 0 ] && [ -e $ALARMFILE ]; then
      mv $ALARMFILE $ALARMFILE.bak
   fi

done < $TEMPFILE
