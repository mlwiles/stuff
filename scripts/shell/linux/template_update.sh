# UPDATE ALL 
yum update all

# CLEANUP LINUX TEMPLATES
yum clean all
find /var/log -type f -exec truncate --size 0 "{}" \;
history -w; history -c
subscription-manager remove --all
subscription-manager unregister
subscription-manager clean