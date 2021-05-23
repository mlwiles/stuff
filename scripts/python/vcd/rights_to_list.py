# 04/21/2021

# Prerequisites:
#	- Must have python3 installed
# 	- Must be able to access host listed below

# To run:
#	- From command line, `python3 rights_to_list.py`
# Expected output:
#	csv ouput of rights
# 
import certifi, urllib3, json, getpass
from base64 import b64encode
from requests.utils import requote_uri

host_list = [
    'https://daldir01.vmware-solutions.cloud.ibm.com',
    'https://fradir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir02.vmware-solutions.cloud.ibm.com',
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

def get_rights(rootURL, bearerToken, client, context):
    # get list of rights bundles
    url = '{0}/cloudapi/1.0.0/{1}?page=1&pageSize=25'.format(rootURL,context)
    headers = { 'Authorization' : bearerToken, 'Accept' : 'application/json;version=34.0' }
    response = client.request("GET", url, headers=headers)
    # parse the response
    data1 = json.loads(response._body.decode('UTF-8'))

    # find the default bundle
    for x in range(len(data1['values'])):
        print(f"{x+1}: {data1['values'][x]['name']}")
    number = int(input("Which item do you want to view: ")) 
    print()

    encid = requote_uri(data1['values'][number-1]['id'])
    
    pagecount = 1
    page = 1
    rights_list = []
    while(page):
        # get the rights from the bundle
        url = '{0}/cloudapi/1.0.0/{1}/{2}/rights?page={3}&pageSize=125'.format(rootURL,context,encid,page)
        headers = { 'Authorization' : bearerToken, 'Accept' : 'application/json;version=34.0' }
        response = client.request("GET", url, headers=headers)
        data2 = json.loads(response._body.decode('UTF-8'))
        pagecount = data2['pageCount']
        page = data2['page']
        
        # get the rights
        for i in data2['values']:
            name = i['name']
            name = name.replace(",", "")
            name = name.replace(": ", ",")
            right = "{0},{1}".format(i['id'],name)
            rights_list.append(right)
        if page == pagecount:
            page = 0
        else:
            page += 1

    # sort and print out the rights
    rights_list.sort()
    print(*rights_list, sep = "\n")
    print(len(rights_list))

    filename = rootURL.replace("https://","")
    filename += "."
    filename += data1['values'][number-1]['name']
    filename = filename.replace(" ",".")
    with open(filename, 'w') as fileout:
        for right in rights_list:
            fileout.write(right)
            fileout.write("\n")

def main():
    client, bearerToken = login(rootURL)
    print(f'1: Rights Bundles')
    print(f'2: Global Roles')
    whichone = int(input("Rights Bundles or Global Roles: "))
    print()

    if whichone == 1:
        get_rights(rootURL, bearerToken, client, "rightsBundles")
    else:
        get_rights(rootURL, bearerToken, client, "globalRoles")

if __name__ == '__main__':
    main()
