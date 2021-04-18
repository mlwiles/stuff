#!/bin/sh

# Script Name     : kube-dbmaint.sh                                                                                             
# Arguments       : none                                                                                           
# Author          : Mike Wiles                                               
# Email           : mwiles@us.ibm.com                                           
# Date            : 2019/02/22       

POD=$(kubectl get pod -l app=fci-primaryds -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD -c fci-primaryds -- bash -c "sudo su -l db2inst1 --command=/fci-primaryds/db_maint.sh"