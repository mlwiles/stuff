# 07/15/2021

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
    'Enter your own URL...'
]
for index in range(len(host_list)):
    print(f'{index+1}: {host_list[index]}')
number = int(input("Which host do you want to connect to: "))
rootURL = host_list[number-1]

if number == len(host_list):
    rootURL = str(input("Enter host full URL (https://host.vmware-solutions.cloud.ibm.com): "))

print()
orgname = str(input("Enter your organization name: "))
print()
sysusr = str(input("Enter your user id for " + orgname + ": "))
print()
syspwd = str(getpass.getpass("Enter your password for " + sysusr + ": "))
print()
syslogin = "{0}@{1}".format(sysusr,orgname)
bearerToken = ""
url = ""
client = ""
filename = orgname
filename += "-vms.csv"

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

def get_vms(rootURL, bearerToken, client):
    # Retrieves a list of vdcs
    # /api/query?type=vm
    print("getting list of vms ... ")
    with open(filename, 'w') as fileout:
        fileout.write("name,guestOs,numberOfCpus,memoryMB")
        fileout.write("\n")      
    print("name,guestOs,numberOfCpus,memoryMB")

    pagesize = 25
    page = 1
    more = 1
    total = 0
    while(more):
        # get the vdcs
        url = '{0}/api/query?type=vm&page={1}&pageSize={2}&format=records'.format(rootURL,page,pagesize)
        print("url"+url)
        headers = { 'x-vcloud-authorization' : bearerToken, 'Accept' : 'application/*+json;version=34.0' }
        response = client.request("GET", url, headers=headers)
        data = json.loads(response._body.decode('UTF-8'))
        print("response"+str(response.status))
        total = data['total']
        print("total"+str(total))
        current = pagesize * page
        if (current > total):
           more = 0
        page += 1
        for i in data['record']:
            href = i['href']
            with open(filename, 'a') as fileout:
                fileout.write(i['name'])
                fileout.write(",")
                fileout.write(i['guestOs'])
                fileout.write(",")
                fileout.write(str(i['numberOfCpus']))
                fileout.write(",")
                fileout.write(str(i['memoryMB']))
            print(i['name'] + "," + i['guestOs'] + "," + str(i['numberOfCpus']) +  "," + str(i['memoryMB']))

def main():
    client, bearerToken = login(rootURL)
    get_vms(rootURL, bearerToken, client)

if __name__ == '__main__':
    main()