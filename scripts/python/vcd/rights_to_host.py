# 04/21/2021

# Prerequisites:
#	- Must have python3 installed
# 	- Must be able to access host listed below

# To run:
#	- From command line, `python3 rights_to_host.py`
# Expected output:
#	csv ouput of rights
# 
import certifi, urllib3, json
from base64 import b64encode
from requests.utils import requote_uri

host_list = [
    'https://daldir01.vmware-solutions.cloud.ibm.com',
    'https://fradir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir02.vmware-solutions.cloud.ibm.com',
    'https://swdcdir01.vmware-solutions.cloud.ibm.com'
]
for index in range(len(host_list)):
    print(f'{index+1}: {host_list[index]}')
number = int(input("Which host do you want to connect to: "))
rootURL = host_list[number-1]

print()
sysusr = str(input("Enter your user id: "))
print()
syspwd = str(input("Enter your password: "))
print()
sysorg = 'System'
syslogin = "{0}@{1}".format(sysusr,sysorg)
bearerToken = ""
url = ""
client = ""

def login(rootURL):
    # setup client 
    client = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
    url = '{0}/api/sessions'.format(rootURL)
    basic = "{0}:{1}".format(syslogin, syspwd)
    base64string = b64encode(bytes(basic, 'utf-8')).decode("ascii")
    authheader =  "Basic %s" % base64string
    headers = { 'Authorization' : authheader, 'Accept' : 'application/json;version=34.0' }
    
    # login 
    response = client.request("POST", url, headers=headers)
    # extract bearer token
    token = response.headers.get('X-VMWARE-VCLOUD-ACCESS-TOKEN')
    bearerToken =  "Bearer %s" % token

    return client, bearerToken

def check_rights(rootURL, bearerToken, client, context):
    print("read in file")
    print("traverse list in file and enable the right")

def main():
    client, bearerToken = login(rootURL)
    print(f'1: Rights Bundles')
    print(f'2: Global Roles')
    whichone = int(input("Rights Bundles or Global Roles: "))
    print()
    
    if whichone == 1:
        check_rights(rootURL, bearerToken, client, "rightsBundles")
    else:
        check_rights(rootURL, bearerToken, client, "globalRoles")

    inputfile = int(input("Path to Rights input: "))
    
if __name__ == '__main__':
    main()
