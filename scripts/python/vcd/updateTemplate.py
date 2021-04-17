from lxml import etree
from pyvcloud.vcd.client import BasicLoginCredentials
from pyvcloud.vcd.client import Client
from pyvcloud.vcd.client import EntityType
from pyvcloud.vcd.org import Org
from pyvcloud.vcd.vdc import VDC
from pyvcloud.vcd.vapp import VApp
from pyvcloud.vcd.vm import VM
from ipaddress import ip_address
from typing import TYPE_CHECKING, Dict, List, Union
from collections import OrderedDict
from requests.packages.urllib3 import disable_warnings

import requests
import os
import pprint
import random
import sys

# Collect arguments.
host = 'sdaldir01.vmware-solutions.cloud.ibm.com'
org = 'dev_665497f29de146fda510727a54c2fafe'
user = 'mwiles'
password = 'REDACTED'
vdc = 'platform-template-curation'
vapp = 'templateCurationVApp'
vm = 'templateCurationVM'
template = 'CentOS-7-Template-Official'
#CentOS-7-Template-Official
#CentOS-8-Template-Official
#RedHat-7-Template-Official
#RedHat-8-Template-Official
#Windows-2016-Template-Official
#Windows-2019-Template-Official

# Disable warnings from self-signed certificates.
requests.packages.urllib3.disable_warnings()

# Login. SSL certificate verification is turned off to allow self-signed
# certificates.  You should only do this in trusted environments.
print("Logging in: host={0}, org={1}, user={2}".format(host, org, user))
client = Client(host, 
                log_file='pyvcloud.log',
                verify_ssl_certs=False)
client.set_highest_supported_version()
client.set_credentials(BasicLoginCredentials(user, org, password))
# get admin users xml view of Director
admin_user_xml = client.get_admin()

print("Accessing Org...")
org_resource = client.get_org()
print (org_resource)
org = Org(client, resource=org_resource)

#print("Accessing VDC...")
#vdc_resource = org.get_vdc(vdc)
#vdc = VDC(client, resource=vdc_resource)
#print("checing for vApps....")
#vapps = vdc.list_resources(EntityType.VAPP)
#for vapp in vapps:
#    print(vapp.get('name'))

#vdc.create_vapp('vapp-centos7')

# Log out.
print("Logging out")
client.logout()