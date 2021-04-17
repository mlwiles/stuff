###############################
# mwiles@us.ibm.com
#
### CHANGE LOG ###
# 2017/07/31 - version1
# 2017/10/04 - version2 - added group support

### PURPOSE ###  
# script to create vcenter sso users for web client

### WHAT TO CHANGE IN THE SCRIPT ###  
# modify the list below for user names $WFSSUsers 
# modify default password $WFSSPassword (be sure to escape characters if needed)
# modify vcenter admin account if needed $vCenterUsername 
# modify vcenter admin password if needed $vCenterPassword (be sure to escape characters if needed)
# modify vcenter ipaddress if needed $vCenterIP 
# modify path to the dir-cli command if needed $DIRCLIcommand 

### BE AWARE OF THE FOLLOWING ### 
# current groups assigned are listed below $GroupArray

### EXECUTION ###
# 1) right click on command prompt and select Run As Administrator ...
# 2) from command line type -- C:\> powershell.exe
# 3) from PS prompt enter the following command 
#    -- PSPrompt> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# 4) change directory to the location of this script 
#    -- C:\>cd <scriptlocation>
# 5) from PS prompt enter the following command: 
#    -- PSPrompt> <scriptName>.ps1

### NOTE ###
# characters that need the be escaped in strings ---> $()*+.[]?\/^{}|
# The escape character for PowerShell is the grave-accent character “`” 
# (which on US keyboards should be in the upper-left of the keyboard to the left of the number 1. 

### TROUBLESHOOTING ###
# if return error message is:
#        LDAP error: Constraint violation 
#        Win Error: The media is write protected.
# This is probably due to password not long enough to does not adhere to policy
###############################


####################################
###  EDIT BELOW HERE FOR USERS  ####
####################################
$vCenterUsername = "Administrator@vsphere.local"
$vCenterPassword = "REDACTED"  ### NOTE ### the characters escaped in the password
$vCenterIP = "10.65.36.223"

$WFSSUsers = @(("jaylani-wfss", "Jaylani", "Sharif", "jaylani@us.ibm.com"), 
               ("mwiles-wfss", "Mike", "Wiles", "mwiles@us.ibm.com"),
			      ("asaidi-wfss", "Abdel", "Saidi", "asaidi@us.ibm.com"),
			      ("anbuchezhian-wfss", "Anbu", "Balakrishnan", "anbuchezhian@us.ibm.com"),
               ("atapu-wfss", "Andra", "Tapu", "Andra.Isabela.Elena.Tapu@us.ibm.com"),
			      ("namaster-wfss", "Nick", "Masters", "namaster@us.ibm.com"),
			      ("rahjandh-wfss", "Rahul", "Jandhyala", "rahjandh@us.ibm.com"),
			      ("rharmswo-wfss", "Robert", "Harmsworth", "rharmswo@ca.ibm.com"))

			 #userid, firstname, lastname, emailaddress
			 
$WFSSGroups = @("Administrators", "Users")
			 #userid, firstname, lastname, emailaddress
			 
$WFSSPassword = "REDACTED"   ### NOTE ### the characters escaped in the password
$DIRCLIcommand = "C:\Program Files\VMware\vCenter Server\vmafdd\dir-cli"
####################################
###  EDIT ABOVE HERE FOR USERS  ####
####################################

#####################
###  CREATEUSER  ####
#####################
# create SSO Users using a vCenter command-line utility that is included within the Platform Services Controller (PSC) called dir-cli
# vCenter Single Sign-On (SSO) Users are typically created using the vSphere Web Client -- Administration > Access > SSO Users and Groups
function createUser ( $params )
{
   $username = $params[0]
   $firstname = $params[1]
   $lastname = $params[2]
   
   write-host "createUser: Creating user: $username"
   write-host "createUser: $DIRCLIcommand" user create --account "$username" --first-name "$firstname" --last-name "$lastname" --user-password "$WFSSPassword" --password "$vCenterPassword"
   &"$DIRCLIcommand" user create --account "$username" --first-name "$firstname" --last-name "$lastname" --user-password "$WFSSPassword" --password "$vCenterPassword"
   
   foreach($groupname in $WFSSGroups)
   { 
     addUserToGroup("$username", "$groupname")
   }
}

#####################
###  CREATEUSER  ####
#####################
# create SSO Users using a vCenter command-line utility that is included within the Platform Services Controller (PSC) called dir-cli
# vCenter Single Sign-On (SSO) Users are typically created using the vSphere Web Client -- Administration > Access > SSO Users and Groups
function addUserToGroup ( $params )
{
   write-host "addUserToGroup: Adding user : $username to group : $groupname"
   write-host "addUserToGroup: $DIRCLIcommand" group modify --name "$groupname" --add "$username" --password "$vCenterPassword"
   &"$DIRCLIcommand" group modify --name "$groupname" --add "$username" --password "$vCenterPassword"
}

###############
###  MAIN  ####
###############
foreach($userinfo in $WFSSUsers)
{ 
   createUser($userinfo)
}



