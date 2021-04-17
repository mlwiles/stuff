###############################
# mwiles@us.ibm.com
#
### CHANGE LOG ###
# 2017/08/01 - version1

### PURPOSE ###
# script to create WAS users and assign them to groups for CFM UI

### WHAT TO CHANGE IN THE SCRIPT ###
# modify the list below for user names - wasUsers
# modify default password - wasUserPassword
# modify the list below for group names - wasGroups
# modify the map below for users to groups - wasGroups

### BE AWARE OF THE FOLLOWING ###
# current groups assigned are listed below usersToGroups

### EXECUTION ###
# 1) open terminal or command window on WAS server host
# 2) cd to WAS wsadmin location
#       Windows default - C:\Program Files\IBM\WebSphere\AppServer\profiles\<profile>\bin
#       Linux default - /opt/IBM/WebSphere/AppServer/profiles/<profile>/bin
#       CFM Profile by default - ICFMProfile
# 3) Run wsadmin command
#       Windows - wsadmin.bat -lang jython -f '<path to script>/<scriptName>.py'
#       Linux - ./wsadmin.sh -lang jython -f '<path to script>/<scriptName>.py'

### NOTE ###
#

### TROUBLESHOOTING ###
#
###############################

import sys
import java.util as jutil
import java.lang as jlang

####################################
###  EDIT BELOW HERE FOR USERS  ####
####################################
wasUserPassword = "REDACTED"
# ["group"]
wasGroups = [
    ["CFAdministrators"],
    ["CFTeamAdmin"],
    ["CFSupervisors"],
    ["CFInvestigators"],
    ["CFTriageAnalysts"],
    ["CFTeamTriage"],
    ["CFTeamInvestigation"],
    ["CFTeamSupervisor"]
]
# ["user", "props", ["groups"]]
wasUsers = [
        ["user1", " -password " + wasUserPassword + " -cn 'User One' -sn User1 -mail user1@mybus.org"],
        ["user2", " -password " + wasUserPassword + " -cn 'User Two' -sn User2 -mail user2@mybus.org"]
]
# ["user", ["groups"]]
wasUsersToWASGroups = [
    ["user1", ["CFAdministrators", "CFTeamAdmin", "CFSupervisors", "CFInvestigators", "CFTriageAnalysts", "CFTeamTriage", "CFTeamInvestigation", "CFTeamSupervisor" ]],
    ["user2", ["CFAdministrators", "CFSupervisors", "CFTeamSupervisor" ]]
]

####################################
###  EDIT ABOVE HERE FOR USERS  ####
####################################

#########################
###  deleteUser(user) ###
#########################
# uses AdminTask to delete a WAS user
def deleteUser(user):
        print "deleteUser:enter"
        try:
                print "deleteUser:deleting  " + user
                AdminTask.deleteUser("[-uniqueName uid=" + user + ",o=defaultWIMFileBasedRealm]")
        #endtry:
        except:
                print "deleteUser:error deleting user " + user
        #endexcept
        return
#enddef
########################
###  userExist(user) ###
########################
# determine if a user exists.
def userExist( name ):
        print "userExist:enter"
        userInfo = None
        try:
                print "userExists:check for user " + name
                userInfo = AdminTask.getUser( "[-uniqueName uid=" + name + ",o=defaultWIMFileBasedRealm]" )
        #endtry
        except:
                print "userExists:error querying user: " + name
        #endexcept
        return userInfo
#enddef
#########################
###  createUser(user) ###
#########################
# uses AdminTask to create WAS user
def createUser(user, props):
        print "createUser:enter"
        try:
                print "createUser:creating user  " + user
                AdminTask.createUser("-uid " + user + props)
        #endtry
        except:
                print "createUser:error creating user " + name
        #endexcept
        return
#enddef
#####################################################
###  createUsers(["user", "props", ["groups"]])   ###
#####################################################
# wrapper method to create list of users (array)
def createUsers(users):
        print "createUsers:enter"
        for user in users:
                print "createUsers:" + user[0]
                userInfo = userExist( user[0] )
                if userInfo != None:
                        print "createUsers:deleteUser"
                        deleteUser( user[0] )
                #endif
                print "createUsers:createUser"
                createUser( user[0], user[1] )
        #endfor
        return
#enddef
###############################
###  groupExist("group")  ###
###############################
# determine if a group exists
def groupExist( group ):
        print "groupExist:enter"
        groupInfo = None
        try:
                uniqueName = "cn=" + group + ",o=defaultWIMFileBasedRealm"
                groupInfo = AdminTask.getGroup( "[-uniqueName " + uniqueName + "]" )
        #endtry
        except:
                print "groupExist:error querying group: " + group
        #endexcept
        return groupInfo
#enddef
###############################
###  createGroup("group")  ###
###############################
# create a VMM group
def createGroup(group):
        print "createGroup:enter"
        try:
                print "createGroup:creating group"
                AdminTask.createGroup("[-cn " + group + " -parent o=defaultWIMFileBasedRealm]")
        #endtry
        except:
                print "createGroup:exception creating group" + group
        #endexcept
        return
#enddef
###############################
###  deleteGroup("group")  ###
###############################
# delete a VMM group
def deleteGroup(group):
        print "deleteGroup:enter"
        try:
                print "deleteGroup:deleting group"
                uniqueName = "cn=" + group + ",o=defaultWIMFileBasedRealm"
                AdminTask.deleteGroup("[-uniqueName " + uniqueName + "]")
        #endtry:
        except:
                print "deleteGroup:exception deleting group" + group
        #endexcept
        return
#enddef
#################################
###  createGroups(["group"])  ###
#################################
# create VMM groups from array
def createGroups(groups):
        print "createGroups:enter"
        for group in groups:
                groupInfo = groupExist( group[0] )
                #if groupInfo != None:
                #       deleteGroup(group[0])
                #endif
                createGroup(group[0])
        #endfor
        return
#enddef
##############################################
###  addUserToGroup("user", ["groups"])  ###
##############################################
# add a VMM user to a VMM group
def addUserToGroup(user, group):
        print "addUserToGroup:enter"
        try:
                print "addUserToGroup:adding"
                AdminTask.addMemberToGroup("[-memberUniqueName uid=" + user + ",o=defaultWIMFileBasedRealm -groupUniqueName cn=" + group + ",o=defaultWIMFileBasedRealm]")
        #endtry
        except:
                print "addUserToGroup:exception adding user to group"
        #except
        return
#enddef
###############################################
###  addUserToGroups(["user", ["groups"]])  ###
###############################################
# add VMM users to VMM groups
def addUsersToGroups(usersToGroups):
        print "addUsersToGroups:enter"
        for user in usersToGroups:
                for group in user[1]:
                        addUserToGroup(user[0], group)
                #endfor
        #endfor
        return
#enddef

###############
###  MAIN  ####
###############

# create list of users
if len( wasUsers ) > 0:
        createUsers( wasUsers )
        AdminConfig.save()
#endif

# create list of groups
if len( wasGroups ) > 0:
        createGroups( wasGroups )
        AdminConfig.save()
#endif

# associate users to groups
if len( wasUsersToWASGroups ) > 0:
        addUsersToGroups( wasUsersToWASGroups )
        AdminConfig.save()
#endif
