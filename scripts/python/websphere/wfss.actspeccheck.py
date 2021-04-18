###############################################################################################################
#
# Script Name     : wfss-actspeccheck.py
# Args            : none
# Author          : Mike Wiles
# Email           : mwiles@us.ibm.com
# Date            : 2019/02/26
# Description     :
# This script is intended to look at the status of the WebSphere Activation Specifications for CFM

# To correct this issue, there are manual steps.  Login to WAS admin console to check activation spec

# To remediate this trigger see above

#  touch /var/log/wfss-actspeccheck.log
#  chmod 777 /var/log/wfss-actspeccheck.log
#
###############################################################################################################

import sys

#/opt/IBM/WebSphere/AppServer/profiles/ICFMProfile/bin/wsadmin.sh -lang jython -user <USER> -password <PWD> -f /home/wfss/wfss-actspeccheck.py

as_file = open('/var/log/wfss.actspeccheck.log','w')

as_id=AdminControl.queryNames('type=J2CMessageEndpoint,ActivationSpec=jms/AnalysisRequestSpec,process=ICFMServer,*')
as_status=AdminControl.invoke(as_id,'getStatus')
as_file.write(as_status)
as_file.write(':AnalysisRequestSpec')
as_file.write('\n')

as_id=AdminControl.queryNames('type=J2CMessageEndpoint,ActivationSpec=jms/AnalysisResponseSpec,process=ICFMServer,*')
as_status=AdminControl.invoke(as_id,'getStatus')
as_file.write(as_status)
as_file.write(':AnalysisResponseSpec')
as_file.write('\n')

as_id=AdminControl.queryNames('type=J2CMessageEndpoint,ActivationSpec=jms/FolioMDBSpec,process=ICFMServer,*')
as_status=AdminControl.invoke(as_id,'getStatus')
as_file.write(as_status)
as_file.write(':FolioMDBSpec')
as_file.write('\n')

as_file.close()
