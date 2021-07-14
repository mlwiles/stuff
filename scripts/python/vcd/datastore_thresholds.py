# 07/13/2021

# Prerequisites:
#	- Must have python3 installed
# 	- Must be able to access host listed below

# To run:
#	- From command line, `python3 datastore_thresholds.py`
# Expected output:
#	csv ouput of datastore details
# 
# Configure Low Disk Space Thresholds for a Provider Virtual Data Center Datastore - 
# https://docs.vmware.com/en/VMware-Cloud-Director/9.7/com.vmware.vcloud.admin.doc/GUID-D512EE6A-0B53-4463-B51B-FD755EF3599B.html?hWord=N4IghgNiBcICZgC5gM6IPYCcCmACRAFjigehHCAL5A
# 
# You can set two thresholds, yellow and red. When you set thresholds on a stand-alone datastore, they apply only to that datastore. If you set thresholds on a storage POD, 
# they apply to all datastores in the storage POD. By default, vCloud Director sets the red threshold to 15% and the yellow threshold to 25% of the stand-alone datastore or 
# POD's total capacity.
# vCloud Director sets the thresholds for all provider virtual data centers that use the datastore. vCloud Director sends an email alert when the datastore crosses the threshold. 
# When a datastore reaches its red threshold, the virtual machine placement engine stops placing new virtual machines on the datastore except for already-placed imported VMs.

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
# create csv file for datastore data output
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

def get_datastores(rootURL, bearerToken, client):
    # get list of datastores
    # /admin/extension/datastores
    # https://vdc-download.vmware.com/vmwb-repository/dcr-public/71e12563-bc11-4d64-821d-92d30f8fcfa1/7424bf8e-aec2-44ad-be7d-b98feda7bae0/doc/doc/operations/GET-DatastoreList.html
    print("getting list of datastores ... ")
    # get the datastores
    url = '{0}/api/admin/extension/datastores'.format(rootURL)
    headers = { 'x-vcloud-authorization' : bearerToken, 'Accept' : 'application/*+json;version=34.0' }
    response = client.request("GET", url, headers=headers)
    data = json.loads(response._body.decode('UTF-8'))
    with open(filename, 'w') as fileout:
        fileout.write("name,thresholdYellowGb,thresholdRedGb,usedCapacityGb,usedCapacityPercent,provisionedSpaceGb,requestedStorageGb,totalCapacityGb   ")
        fileout.write("\n")      
    for i in data['reference']:
        href = i['href']
        get_datastore(href, bearerToken, client)

def get_datastore(href, bearerToken, client):
    # get datastore
    # /admin/extension/datastore/{id}
    # https://vdc-download.vmware.com/vmwb-repository/dcr-public/71e12563-bc11-4d64-821d-92d30f8fcfa1/7424bf8e-aec2-44ad-be7d-b98feda7bae0/doc/doc/operations/GET-Datastore.html
    # dump the contents of the datastores out to a CSV file
    print('getting datastore - {0}'.format(href))
    headers = { 'x-vcloud-authorization' : bearerToken, 'Accept' : 'application/*+json;version=34.0' }
    response = client.request("GET", href, headers=headers)
    data = json.loads(response._body.decode('UTF-8'))
    with open(filename, 'a') as fileout:
        fileout.write(data['name'])
        fileout.write(",")
        fileout.write(str(data['thresholdYellowGb']))
        fileout.write(",")
        fileout.write(str(data['thresholdRedGb']))
        fileout.write(",")
        fileout.write(str(data['usedCapacityGb']))
        fileout.write(",")
        fileout.write(str(data['usedCapacityPercent']))
        fileout.write(",")
        fileout.write(str(data['provisionedSpaceGb']))
        fileout.write(",")
        fileout.write(str(data['requestedStorageGb']))
        fileout.write(",")
        fileout.write(str(data['totalCapacityGb']))
        fileout.write("\n")
    
    set_datastore(href, data['name'], data['id'], bearerToken, client)

def set_datastore(paramhref, paramname, paramid, parambearerToken, paramclient):
    # set datastore
    # /admin/extension/datastore/{id}
    # https://vdc-download.vmware.com/vmwb-repository/dcr-public/71e12563-bc11-4d64-821d-92d30f8fcfa1/7424bf8e-aec2-44ad-be7d-b98feda7bae0/doc/doc/operations/PUT-Datastore.html
    # set all thresholds for YELLOW = 1000GB, RED = 500GB
    print('updating datastore - {0}'.format(paramhref))
    headers = { 'x-vcloud-authorization' : parambearerToken, 'Content-Type' : 'application/vnd.vmware.admin.datastore+xml', 'Accept' : 'application/vnd.vmware.admin.datastore+xml;version=34.0' }
    data = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
              <vmext:Datastore xmlns="http://www.vmware.com/vcloud/v1.5" 
                               xmlns:vmext="http://www.vmware.com/vcloud/extension/v1.5" 
                               xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1" 
                               xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData" 
                               xmlns:common="http://schemas.dmtf.org/wbem/wscim/1/common" 
                               xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" 
                               xmlns:vmw="http://www.vmware.com/schema/ovf" 
                               xmlns:ovfenv="http://schemas.dmtf.org/ovf/environment/1" 
                               xmlns:ns9="http://www.vmware.com/vcloud/versions" 
                               name="{herename}" 
                               id="urn:vcloud:datastore:{hereid}" 
                               href="{herehref}" 
                               type="application/vnd.vmware.admin.datastore+xml">
                  <vmext:ThresholdYellowGb>1000</vmext:ThresholdYellowGb>
                  <vmext:ThresholdRedGb>500</vmext:ThresholdRedGb>
              </vmext:Datastore>"""

    data.format(herename=paramname, hereid=paramid, herehref=paramhref)
    response = paramclient.request("PUT", paramhref, body=data, headers=headers)

def main():
    client, bearerToken = login(rootURL)
    get_datastores(rootURL, bearerToken, client)

if __name__ == '__main__':
    main()