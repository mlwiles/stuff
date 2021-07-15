# 07/13/2021

# Prerequisites:
#	- Must have python3 installed
# 	- Must be able to access host listed below

# To run:
#	- From command line, `python3 vdc-guarantee.py`
# Expected output:
#	csv ouput of vdc compute capacity
# 
from os import name
import certifi, urllib3, json, getpass
from base64 import b64encode
from requests.utils import requote_uri

host_list = [
    'https://daldir01.vmware-solutions.cloud.ibm.com',
    'https://fradir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir03.vmware-solutions.cloud.ibm.com',
    'https://sdaldir04.vmware-solutions.cloud.ibm.com',
    'https://swdcdir01.vmware-solutions.cloud.ibm.com',
    'Enter your own URL...'
]
for index in range(len(host_list)):
    print(f'{index+1}: {host_list[index]}')
number = int(input("Which host do you want to connect to: "))
rootURL = host_list[number-1]

if number == len(host_list):
    rootURL = str(input("Enter host full URL (https://host.vmware-solutions.cloud.ibm.com): "))

print()
sysusr = str(input("Enter your user id for " + rootURL + ": "))
print()
syspwd = str(getpass.getpass("Enter your password for " + sysusr + ": "))
print()
sysorg = 'System'
syslogin = "{0}@{1}".format(sysusr,sysorg)
bearerToken = ""
url = ""
client = ""
filename = rootURL.replace("https://","")
filename += ".csv"

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
    token = response.headers.get('x-vcloud-authorization')
    bearerToken = token
    return client, bearerToken

def get_vdcs(rootURL, bearerToken, client):
    # Retrieves a list of vdcs
    # /admin/extension/orgVdcs/query
    # https://code.vmware.com/apis/912/vmware-cloud-director/doc/doc/operations/GET-OrgVdcsAllFromQuery.html
    print("getting list of vdcs ... ")
    with open(filename, 'w') as fileout:
        fileout.write("name,allocationModel,cpu-allocated,cpu-limit,cpu-reserved,mem-allocated,mem-limit,mem-reserved")
        fileout.write("\n")      

    pagesize = 25
    page = 1
    more = 1
    total = 0
    while(more):
        # get the vdcs
        url = '{0}/api/admin/extension/orgVdcs/query?page={1}&pageSize={2}'.format(rootURL,page,pagesize)
        headers = { 'x-vcloud-authorization' : bearerToken, 'Accept' : 'application/*+json;version=34.0' }
        response = client.request("GET", url, headers=headers)
        data = json.loads(response._body.decode('UTF-8'))
        total = data['total']
        print(total)
        current = pagesize * page
        if (current > total):
           more = 0
        page += 1
        for i in data['record']:
            href = i['href']
            get_vdc(href, bearerToken, client)

def get_vdc(href, bearerToken, client):
    # get vdc
    # /admin/vdc/{id}
    # https://code.vmware.com/apis/912/vmware-cloud-director/doc/doc/operations/GET-Vdc-AdminView.html
    print('getting vdc - {0}'.format(href))
    headers = { 'x-vcloud-authorization' : bearerToken, 'Accept' : 'application/*+json;version=34.0' }
    response = client.request("GET", href, headers=headers)
    data = json.loads(response._body.decode('UTF-8'))
    with open(filename, 'a') as fileout:
        fileout.write(data['name'])
        fileout.write(",")
        fileout.write(str(data['allocationModel']))
        fileout.write(",")
        fileout.write(str(data['computeCapacity']['cpu']['allocated']))
        fileout.write(",")
        fileout.write(str(data['computeCapacity']['cpu']['limit']))
        fileout.write(",")
        fileout.write(str(data['computeCapacity']['cpu']['reserved']))
        fileout.write(",")
        fileout.write(str(data['computeCapacity']['memory']['allocated']))
        fileout.write(",")
        fileout.write(str(data['computeCapacity']['memory']['limit']))
        fileout.write(",")
        fileout.write(str(data['computeCapacity']['memory']['reserved']))
        fileout.write("\n")

def main():
    client, bearerToken = login(rootURL)
    get_vdcs(rootURL, bearerToken, client)

if __name__ == '__main__':
    main()