#!/bin/sh
###############################################################################################################
# 
# Script Name     : wfss-kubepodcheck.sh                                                                                             
# Args            : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/22                                          
# Description     :                                                                                 
# This script is intended to look at the status of the kubernetes pods.  It will report back the status
# if anything other Running or Completed. 

#                    Reference -        https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
# PodScheduled       the Pod has been scheduled to a node;
# Ready              the Pod is able to serve requests and should be added to the load balancing pools of all matching Services;
# Initialized        all init containers have started successfully;
# Unschedulable      the scheduler cannot schedule the Pod right now, for example due to lacking of resources or other constraints;
# ContainersReady    all containers in the Pod are ready.

# Pending	         The Pod has been accepted by the Kubernetes system, but one or more of the Container images has not been created. 
#                    This includes time before being scheduled as well as time spent downloading images over the network, which could take a while.
# Running	         The Pod has been bound to a node, and all of the Containers have been created. At least one Container is still running, 
#                    or is in the process of starting or restarting.
# Succeeded	         All Containers in the Pod have terminated in success, and will not be restarted.
# Failed	            All Containers in the Pod have terminated, and at least one Container has terminated in failure. That is, the Container either 
#                    exited with non-zero status or was terminated by the system.
# Unknown	         For some reason the state of the Pod could not be obtained, typically due to an error in communicating with the host of the Pod.
# Completed	         The pod has run to completion as there’s nothing to keep it running eg. Completed Jobs.
# CrashLoopBackOff	This means that one of the containers in the pod has exited unexpectedly, and perhaps with a non-zero error code even 
#                    after restarting due to restart policy.

# To correct this issue, there are manual steps.  Situation will dictate on how to remediate the pod status

# To remediate this trigger, simply address the old directories (e.g. delete) and delete the file $ALARMFILE
# 
###############################################################################################################

TEMPFILE="/var/log/wfss.kubepodcheck.tmp"
ALARMFILE="/var/log/wfss.kubepodcheck.alarm"
ALARM=0

kubectl get pods > $TEMPFILE
if [ -e $ALARMFILE ]; then
   echo "" > $ALARMFILE
fi

while IFS='' read -r KUBE || [[ -n "$KUBE" ]]; do

   IFS=' ' read -r NAME READY STATUS RESTARTS AGE <<< "$KUBE"

   if [ $NAME != "NAME" ]; then
      if [ $STATUS == "Running" ]; then
         IFS='/' read -r READYACTUAL READYTOTAL <<< "$READY"
         if [ $READYACTUAL != $READYTOTAL ]; then
           echo ${STATUS^^} $READY $NAME >> $ALARMFILE
           ALARM=1
         fi
      fi
      if [ $STATUS != "Running" ] && [ $STATUS != "Completed" ]; then
         echo ${STATUS^^}:$NAME >> $ALARMFILE
         ALARM=1
      fi
   fi

   if [ ALARM == 0 ] && [ -e $ALARMFILE ]; then
      mv $ALARMFILE $ALARMFILE.bak
   fi

done < $TEMPFILE


------------------------------------------------------------------------

TEMPFILE="/var/log/wfss.kubepodcheck.out"
ALARMFILE_TMP="/var/log/wfss.kubepodcheck.tmp"
ALARMFILE_PREV="/var/log/wfss.kubepodcheck.prev"
ALARMFILE="/var/log/wfss.kubepodcheck.alarm"
MV="/usr/bin/mv"
RM="/usr/bin/rm"
ALARM=0

kubectl get pods > $TEMPFILE
if [ -e $ALARMFILE_TMP ]; then
   echo "" > $ALARMFILE_TMP
fi

while IFS='' read -r KUBE || [[ -n "$KUBE" ]]; do

   IFS=' ' read -r NAME READY STATUS RESTARTS AGE <<< "$KUBE"

   if [ $NAME != "NAME" ]; then
      if [ $STATUS == "Running" ]; then
         IFS='/' read -r READYACTUAL READYTOTAL <<< "$READY"
         if [ $READYACTUAL != $READYTOTAL ]; then
           echo ${STATUS^^} $READY $NAME >> $ALARMFILE_TMP
           ALARM=1
         fi
      fi
      if [ $STATUS != "Running" ] && [ $STATUS != "Completed" ]; then
         NEW_STATUS=`echo ${STATUS^^} | sed -e 's/:/\ /g'`
         echo ${NEW_STATUS} $NAME >> $ALARMFILE_TMP
         ALARM=1
      fi
   fi

done < $TEMPFILE

if [ $ALARM == 0 ] && [ -e $ALARMFILE ]; then
   # Alarm is 0 and previous alarm file exists - Save Previous Alarm & Delete Alarm Temp File
   $MV -f $ALARMFILE $ALARMFILE_PREV
   $RM -f $ALARMFILE_TMP
elif [ $ALARM == 0 ] && [ ! -e $ALARMFILE ]; then
   # Alarm is 0 and previous alarm file does not exist - Delete Alarm Temp File
   $RM -f $ALARMFILE_TMP
elif [ $ALARM == 1 ] && [ -e $ALARMFILE ]; then
   # Alarm is 1 and previous alarm file exists - Save Previous Alarm
   $MV -f $ALARMFILE $ALARMFILE_PREV
   $MV -f $ALARMFILE_TMP $ALARMFILE
else
   # Alarm is 1 - New Alarm Generated
   $MV -f $ALARMFILE_TMP $ALARMFILE
fi