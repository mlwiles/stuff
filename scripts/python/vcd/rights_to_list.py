# 04/19/2021

# Prerequisites:
#	- Must have python3 installed
# 	- Must be able to access host listed below

# To run:
#	- From command line, `python3 rights_to_list.py`
# Expected output:
#	csv ouput of rights
# 
import requests, certifi, urllib, urllib3, json
from requests.auth import HTTPDigestAuth
from base64 import b64encode
from requests.utils import requote_uri

host_list = [
    'https://daldir01.vmware-solutions.cloud.ibm.com',
    'https://fradir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir02.vmware-solutions.cloud.ibm.com',
    'https://ssao01dir01.vmware-solutions.cloud.ibm.com'
]
for index in range(len(host_list)):
    print(f'{index+1}: {host_list[index]}')
number = int(input("Which host do you want to connect to:"))
rootURL = host_list[number-1]
print()
sysusr = str(input("Enter your user id:"))
print()
syspwd = str(input("Enter your password:"))
print()
sysorg = 'System'
syslogin = "{0}@{1}".format(sysusr,sysorg)

# setup client 
client = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())
url = '{0}/api/sessions'.format(rootURL)
basic = "{0}:{1}".format(syslogin, syspwd)
base64string = b64encode(bytes(basic, 'utf-8')).decode("ascii")
authheader =  "Basic %s" % base64string
headers = { 'Authorization' : authheader, 'Accept' : 'application/json;version=34.0' }

# login 
response = client.request("POST", url, headers=headers)
status_code = response.status
# extract bearer token
token = response.headers.get('X-VMWARE-VCLOUD-ACCESS-TOKEN')
bearerToken =  "Bearer %s" % token

# get list of rights bundles
url = '{0}/cloudapi/1.0.0/rightsBundles?page=1&pageSize=25'.format(rootURL)
headers = { 'Authorization' : bearerToken, 'Accept' : 'application/json;version=34.0' }
response = client.request("GET", url, headers=headers)
# parse the response
data = json.loads(response._body.decode('UTF-8'))

# find the default bundle
defaultid = ""
for i in data['values']:
    if i['name'] == 'Default Rights Bundle':
        defaultid = i['id']

# get the rights from the bundle
encid = requote_uri(defaultid)
url = '{0}/cloudapi/1.0.0/rightsBundles/{1}/rights?page=1&pageSize=125'.format(rootURL,encid)
headers = { 'Authorization' : bearerToken, 'Accept' : 'application/json;version=34.0' }
response = client.request("GET", url, headers=headers)
data = json.loads(response._body.decode('UTF-8'))

# get the rights
rights_list = []
for i in data['values']:
    right = "{0} == {1}".format(i['id'],i['name'])
    rights_list.append(right)

# get the rights from the bundle - second page
url = '{0}/cloudapi/1.0.0/rightsBundles/{1}/rights?page=2&pageSize=125'.format(rootURL,encid)
headers = { 'Authorization' : bearerToken, 'Accept' : 'application/json;version=34.0' }
response = client.request("GET", url, headers=headers)
data = json.loads(response._body.decode('UTF-8'))

# get the rights
for i in data['values']:
    right = "{0} == {1}".format(i['id'],i['name'])
    rights_list.append(right)

# sort and print out the rights
rights_list.sort()
print(*rights_list, sep = "\n")
print(len(rights_list))
