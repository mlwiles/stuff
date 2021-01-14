============setup drive for MQ============
fdisk -l
mkfs.ext4 /dev/sde
mount -t ext4 /dev/sde /mqlogs
mkdir /mqlogging
mkdir /mqlogging/mqm

vi /var/mqm/qmgrs/CFQM/qm.ini
   LogPath=/mqlogging/mqm/CFQM/

mkdir /mqlogging/mqm/CFQM
chown -R mqm:mqm /mqlogging/mqm
mount -t ext4 /dev/sde /mqlogging/

vi /etc/fstab
   /dev/sdd /mqlogging ext4 defaults 1 1

============Linux Installing SSD============
If LUKS is enabled on an image, you will be prompted for passphrase every reboot
To get around this, create a keyfile and associate it with each device / LUKS vg, partition, etc
 
============Linux LUKS prompting============
Step 1: Create a random keyfile
dd if=/dev/urandom of=/root/keyfile bs=1024 count=4

Step 2: Make the keyfile read-only to root
chmod 0400 /root/keyfile

Step 3: Add the keyfile to LUKS
cryptsetup luksAddKey /dev/sdX /root/keyfile

Step 4: Create a mapper
vi /etc/crypttab
sdX_crypt      /dev/sdX  /root/keyfile  luks

============RHN============
Reconfigure your RHEL system to use the IBM internal Red Hat Satellite server by running the following command as root (it's a capital O, not a zero):
wget -qO- --no-check-certificate https://rhn.linux.ibm.com/pub/bootstrap/bootstrap.sh | /bin/bash

The bootstrap.sh script is used to quickly setup your RHEL system so that updates are pulled from the IBM Internal Red Hat Satellite. This script makes changes to the /etc/sysconfig/rhn/up2date config file and installs the public SSL certificate used by the rhn.linux.ibm.com server.

If the previous command was successful, you should see an output similar to the following:

[root@ltcinfrastructure ~]# wget -qO- --no-check-certificate https://rhn.linux.ibm.com/pub/bootstrap/bootstrap.sh | /bin/bash
RHN Satellite Server Client bootstrap script v4.0

UPDATING RHN_REGISTER/UP2DATE CONFIGURATION FILES
-------------------------------------------------
* downloading necessary files
  client_config_update.py...
  client-config-overrides-rtp.txt...
* running the update scripts
  . up2date config file

* attempting to install corporate public CA cert
Retrieving http://rhn.linux.ibm.com/pub/rhn-org-trusted-ssl-cert-1.0-10.noarch.rpm
Preparing...                ##################################################
-bootstrap complete-

Register your RHEL system by running the following command as root and using your Enterprise Linux FTP user id (the same as your intranet id) and password:
rhnreg_ks --force --username=user@<cc>.ibm.com --password=your_ftp3_passwd

 