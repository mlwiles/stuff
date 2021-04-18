import re
import subprocess
serverlist = subprocess.Popen(['ibmcloud', 'sl', 'hardware', 'list'], 
             stdout=subprocess.PIPE, 
             stderr=subprocess.STDOUT)
stdout,stderr = serverlist.communicate()

serverlistdecode = stdout.decode('UTF-8')
#print(serverlistdecode)

list_of_servers = []
servers = re.split('\n', serverlistdecode)
for server in servers:
    serverdatas = re.split(' +', server)
    if serverdatas[0] and not serverdatas[0] == "id":
        credentials = subprocess.Popen(['ibmcloud', 'sl', 'hardware', 'credentials', serverdatas[0]], 
                      stdout=subprocess.PIPE, 
                      stderr=subprocess.STDOUT)
        stdout,stderr = credentials.communicate()
        credentialsdecode = stdout.decode('UTF-8')
        
        servercreds = re.split('\n', credentialsdecode)
        for servercred in servercreds:
            creds = re.split(' +', servercred)
            list_of_server_details = []
            if creds[0] and creds[0] == "root":
                list_of_server_details.append(serverdatas[1])
                list_of_server_details.append(serverdatas[2])
                list_of_server_details.append(serverdatas[4])
                list_of_server_details.append(creds[1])
                #print(f"{serverdatas[1]}.{serverdatas[2]}   {serverdatas[4]}   {creds[0]} / {creds[1]}")
                list_of_servers.append(list_of_server_details)

print(list_of_servers)

with open('sl-hosts.xml', 'w') as fileout:
    for serveritems in list_of_servers:
        out = serveritems[0] + "." + serveritems[1] + ", " + serveritems[2] + ", " + serveritems[3] + "\n"
        fileout.write(out)