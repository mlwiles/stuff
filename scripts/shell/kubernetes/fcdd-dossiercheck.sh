#!/bin/sh
###############################################################################################################
# # # # # #                  bc need to be installed on machine this runs on                        # # # # # # 
###############################################################################################################
# 
# Script Name     : fcdd-dossiercheck.sh                                                                                             
# Arguments       : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/20                                          
# Description     :   
# This script is intended to check the availability of the dossier service in the liberty container for fcdd
# The script will try to 'ping' the service and if it replies try to determine the memory utilization as there
# appears to be a memory leak.  Based on the utilization a restart might be required
# If the service does on reply, a restart is attempted.
#
###############################################################################################################

IP=$(/usr/sbin/ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -E '(10\.)')
PING=$(/usr/bin/curl -s http://$IP:9083/DossierService/IsActive | tr -d '\n')
DATE=$(date)
POD=$(kubectl get pod -l app=fci-due-diligence-liberty -o jsonpath="{.items[0].metadata.name}")
RESTART=0
MONFILENAME="/var/log/wfss.dossier.mon"
ALARMFILE="/var/log/wfss.dossier.alarm"
MAXFILESIZE=100000

echo "$PING"
echo "Pod:" $POD "--" $DATE >> $MONFILENAME

###############################################################################################################
#  if service is ping-able, just log ... otherwise restart
###############################################################################################################
if [ "$PING" == "PDF Service is  active" ]; then
   if [ -e "$ALARMFILE" ]; then
      rm $ALARMFILE
   fi
   #   MEMORY=$(kubectl exec -it $POD -c liberty -- bash -c "ps auwx | grep -i ws-server.jar | grep -i dossier-server | grep -v color=auto | awk '{print \"Total:\"\$5\" Consumed:\"\$6}'")
   TOTAL=$(kubectl exec -it $POD -c liberty -- bash -c "ps auwx | grep -i ws-server.jar | grep -i dossier-server | grep -v color=auto | awk '{print \$5}' | tr -d '[:space:]'")
   USED=$(kubectl exec -it $POD -c liberty -- bash -c "ps auwx | grep -i ws-server.jar | grep -i dossier-server | grep -v color=auto | awk '{print \$6}' | tr -d '[:space:]'")
   echo "Total:" $TOTAL
   echo "Total:" $TOTAL >> $MONFILENAME
   echo "Used:" $USED
   echo "Used:" $USED >> $MONFILENAME
   PERCENT=$(echo "scale=2;( $USED / $TOTAL ) * 100" | bc)
   echo "Percentange of memory used: " $PERCENT
   echo "Percentange of memory used: " $PERCENT >> $MONFILENAME
   MEMUSED=$(echo "$PERCENT > 75.00" | bc )
   if [ "$MEMUSED" = "1" ]; then
      RESTART=1
   fi
else
   RESTART=1
fi

###############################################################################################################
#  check if restart is required
###############################################################################################################
if [ "$RESTART" = "1" ]; then
   #   try to restart the liberty service
   echo "PDF Service down ..." >> $MONFILENAME
   kubectl exec -it $POD -c liberty -- bash -c "cd /opt/ibm/wlp;./bin/server stop dossier-server;./bin/server start dossier-server"
   echo "Liberty POD restarted" >> $ALARMFILE

   #   sleep for 1 minute
   sleep 1m

   #   check the service is up
   PING=$(curl -s http://$IP:9083/DossierService/IsActive | tr -d '\n')

   if [ "$PING" == "PDF Service is  active" ]; then
      echo "PDF Service restarted" >> $MONFILENAME
      if [ -e "$ALARMFILE" ]; then
         rm $ALARMFILE
      fi   
   else
/liberty      #   delete the pod
      echo "Liberty POD restarted" >> $MONFILENAME
      echo "Liberty POD restarted" >> $ALARMFILE
      kubectl delete pod $POD
   fi
fi