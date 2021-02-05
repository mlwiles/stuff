#!/bin/bash

echo "#!/bin/bash" > /tmp/template_update.sh
echo "clear" > /tmp/template_update.sh
echo "echo \"***************************************\"" >> /tmp/template_update.sh
echo "echo \"****** UPDATE ALL INSTALLED RPMS ******\"" >> /tmp/template_update.sh
echo "echo \"***************************************\"" >> /tmp/template_update.sh
echo "yum -y update" >> /tmp/template_update.sh
chmod +x /tmp/template_update.sh

echo "#!/bin/bash" > /tmp/template_cleanup.sh
echo "clear" > /tmp/template_cleanup.sh
echo "echo \"*******************************\"" >> /tmp/template_cleanup.sh
echo "echo \"****** CLEANUP YUM CACHE ******\"" >> /tmp/template_cleanup.sh
echo "echo \"*******************************\"" >> /tmp/template_cleanup.sh
echo "yum clean all" >> /tmp/template_cleanup.sh

echo "echo \"********************************************\"" >> /tmp/template_cleanup.sh
echo "echo \"****** CLEANUP THE /var/log LOG FILES ******\"" >> /tmp/template_cleanup.sh
echo "echo \"********************************************\"" >> /tmp/template_cleanup.sh
echo "find /var/log -type f -exec truncate --size 0 \"{}\" \\; " >> /tmp/template_cleanup.sh

echo "echo \"*****************************************\"" >> /tmp/template_cleanup.sh
echo "echo \"****** CLEAR HISTORY FOR ROOT USER ******\"" >> /tmp/template_cleanup.sh
echo "echo \"*****************************************\"" >> /tmp/template_cleanup.sh
echo "cat /dev/null > ~/.bash_history" >> /tmp/template_cleanup.sh
echo "history -w" >> /tmp/template_cleanup.sh
echo "history -c" >> /tmp/template_cleanup.sh

echo "#echo \"**************************\"" >> /tmp/template_cleanup.sh
echo "#echo \"****** CLEANUP /TMP ******\"" >> /tmp/template_cleanup.sh
echo "#echo \"**************************\"" >> /tmp/template_cleanup.sh
echo "#rm -rf /tmp/vmware-*" >> /tmp/template_cleanup.sh
echo "#rm -rf /tmp/std*" >> /tmp/template_cleanup.sh
echo "#rm -rf /tmp/systemd-private-*" >> /tmp/template_cleanup.sh

echo "echo \"**************************************************************************\"" >> /tmp/template_cleanup.sh
echo "echo \"****** REMOVE SCRIPTS AND SHUTDOWN THE IMAGE IN PREP FOR TEMPLITIZE ******\"" >> /tmp/template_cleanup.sh
echo "echo \"**************************************************************************\"" >> /tmp/template_cleanup.sh
echo "rm -rf /tmp/template_update.sh" >> /tmp/template_cleanup.sh
echo "rm -rf /tmp/template_cleanup.sh" >> /tmp/template_cleanup.sh

echo "echo \"******************************************************\"" >> /tmp/template_cleanup.sh
echo "echo \"****** shutdown now OR use terraform to cleanup ******\"" >> /tmp/template_cleanup.sh
echo "echo \"******************************************************\"" >> /tmp/template_cleanup.sh
chmod +x /tmp/template_cleanup.sh
