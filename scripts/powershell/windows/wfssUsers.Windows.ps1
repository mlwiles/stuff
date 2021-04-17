###############################
# mwiles@us.ibm.com
#
### CHANGE LOG ###
# 2017/07/31 - version1
# 2017/10/04 - version2 - cleanup


### PURPOSE ###  
# script to create windows users and assign to groups

### WHAT TO CHANGE IN THE SCRIPT ###  
# modify the list below for user names $WFSSUsers 
# modify the list below for groups $WindowsGroups if needed 
# modify default password $WFSSPassword (be sure to escape characters if needed)

### BE AWARE OF THE FOLLOWING ### 
# current groups assigned are listed below $WindowsGroups

### EXECUTION ###
# 1) right click on command prompt and select Run As Administrator ...
# 2) from command line type -- C:\> powershell.exe
# 3) from PS prompt enter the following command 
#    -- PSPrompt> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# 4) change directory to the location of this script 
#    -- C:\>cd <scriptlocation>
# 5) from PS prompt enter the following command: 
#    -- PSPrompt> <scriptName>.ps1
###############################

####################################
###  EDIT BELOW HERE FOR USERS  ####
####################################
$WFSSUsers = @(("jaylani-wfss", "Jaylani", "Sharif", "jaylani@us.ibm.com","REDACTED"), 
("mwiles-wfss", "Mike", "Wiles", "mwiles@us.ibm.com","REDACTED"))

			 
$WFSSPassword = "REDACTED"   ### NOTE ### the characters escaped in the password
$WFSSDescription = "User created for Walls Fargo"
$WindowsGroups = @("Users", "Remote Desktop Users")
####################################
###  EDIT ABOVE HERE FOR USERS  ####
####################################


# ADS_USER_FLAG_ENUM Enumeration
# http://msdn.microsoft.com/en-us/library/aa772300(VS.85).aspx
$ADS_UF_SCRIPT                                  = 1   # 0x1
$ADS_UF_ACCOUNTDISABLE                          = 2   # 0x2
$ADS_UF_HOMEDIR_REQUIRED                        = 8   # 0x8
$ADS_UF_LOCKOUT                                 = 16  # 0x10
$ADS_UF_PASSWD_NOTREQD                          = 32  # 0x20
$ADS_UF_PASSWD_CANT_CHANGE                      = 64  # 0x40
$ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED         = 128  # 0x80
$ADS_UF_TEMP_DUPLICATE_ACCOUNT                  = 256  # 0x100
$ADS_UF_NORMAL_ACCOUNT                          = 512  # 0x200
$ADS_UF_INTERDOMAIN_TRUST_ACCOUNT               = 2048  # 0x800
$ADS_UF_WORKSTATION_TRUST_ACCOUNT               = 4096  # 0x1000
$ADS_UF_SERVER_TRUST_ACCOUNT                    = 8192  # 0x2000
$ADS_UF_DONT_EXPIRE_PASSWD                      = 65536  # 0x10000
$ADS_UF_MNS_LOGON_ACCOUNT                       = 131072 # 0x20000
$ADS_UF_SMARTCARD_REQUIRED                      = 262144 # 0x40000
$ADS_UF_TRUSTED_FOR_DELEGATION                  = 524288 # 0x80000
$ADS_UF_NOT_DELEGATED                           = 1048576 # 0x100000
$ADS_UF_USE_DES_KEY_ONLY                        = 2097152 # 0x200000
$ADS_UF_DONT_REQUIRE_PREAUTH                    = 4194304 # 0x400000
$ADS_UF_PASSWORD_EXPIRED                        = 8388608 # 0x800000
$ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION  = 16777216 # 0x1000000

#####################
###  CREATEUSER  ####
#####################
# uses Active Directory Service Interfaces (ADSI) to create users
function createUser ( $userInfo )
{
   $username = $userInfo[0]
   $firstname = $userInfo[1]
   $lastname = $userInfo[2]
   $password = $userInfo[4]
 
   write-host "createUser: Creating user: $username"
   $ADSIComputer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer"
   try {
      $ADSIUser = $ADSIComputer.Create("User", $username)
      $ADSIUser.SetPassword($password)   ####default passord is IBM4you2!
      $ADSIUser.SetInfo()
      $ADSIUser.FullName = "$firstname $lastname"
      $ADSIUser.SetInfo()
      $ADSIUser.Description = $WFSSDescription
      $ADSIUser.SetInfo()
      $ADSIUser.UserFlags = $ADS_UF_DONT_EXPIRE_PASSWD
      $ADSIUser.SetInfo()
      write-host "createUser: User created: $username"
   } catch {
      write-host "createUser: User $username was not created"
   }
}

####################
###  ADDGROUPS  ####
####################
# uses Active Directory Service Interfaces (ADSI) to assign users to group
function addGroups ( $userInfo )
{
   $username = $userInfo[0]

   foreach ($Group in $WindowsGroups) {
      write-host "addGroups: Adding user to $group : $username"
      $ADSIGroup = [ADSI]"WinNT://$env:computername/$group,group"
      try {
         $ADSIGroup.Add("WinNT://$env:computername/$username,user")
      } catch {
         write-host "addGroups: User $username was not added to group: $group"
      }
   }
   write-host "addGroups: User completed: $username"
}

###############
###  MAIN  ####
###############
foreach($userinfo in $WFSSUsers)
{ 
   createUser($userinfo)   
   addGroups($userinfo)
}


