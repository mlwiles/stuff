#!/usr/bin/perl

###############################
# mwiles@us.ibm.com
#
### CHANGE LOG ###
# 2017/07/31 - version1

### PURPOSE ###  
# script to create linux users and assign groups

### WHAT TO CHANGE IN THE SCRIPT ###  
# modify the list below for user names $WFSSUsers 
# modify the list below for groups @WindowsGroups if needed 
# modify default password $WFSSPassword (be sure to escape characters if needed)


### BE AWARE OF THE FOLLOWING ### 
# current groups assigned are listed below @LinuxGroups

### EXECUTION ###
# 1) allow executable permissions --  chmod +x <scriptName>.pl
# 2) from shell enter the following command: --  ./<scriptName>.pl

### NOTE ###
#

### TROUBLESHOOTING ###
# 
###############################

####################################
###  EDIT BELOW HERE FOR USERS  ####
####################################
@WFSSUsers = ("jaylani-wfss", 
              "mwiles-wfss", 
              "asaidi-wfss", 
			     "anbuchezhian-wfss",
              "atapu-wfss", 
			     "rahjandh-wfss"); #comma delimted list of users
$WFSSGroup = "wfss";
$WFSSPassword = "REDACTED";
$WFSSDescription = "User created for WFSS mgmt";
@LinuxGroups = ("root");  #comma delimted list of groups
####################################
###  EDIT ABOVE HERE FOR USERS  ####
####################################

# default group for wfss users
print "adding the group:$WFSSGroup\n";
system("groupadd -g $WFSSGroup");

# md5 the password
my $md5password = `openssl passwd -1 $WFSSPassword`;
chomp($md5password);

# loop thought list of users
foreach $user (@WFSSUsers)
{
   chomp($user);
   print "creating user:$user\n";
   system("useradd -s /bin/bash -d /home/$username -g $WFSSGroup -p \'$md5password\' $user");
   foreach $group (@LinuxGroups) 
   {
      chomp($group);
      print "adding user:$user to group:$group\n";
      system("usermod -a -G $group $user");
   }
}

