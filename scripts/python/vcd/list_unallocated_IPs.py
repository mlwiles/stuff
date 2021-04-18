# 04/08/2020

# Prerequisites:
#	- Must have python3 installed
#	- Must have etree installed
#		- To install on MacOS: python3 -m pip install etree
#	- Must have lxml installed
#		- To install on MacOS: python3 -m pip install lxml
#	- Must have pyvcloud installed
#		- To install on MacOS: pip install pyvcloud
# 	- Must be able to access host listed below

# To run:
#	- From command line, `python3 list_IP_staging.py`
# Expected output:
#	List of Allocated IPs
#	List of Provisioned IPs
#	List of Available IPs

from lxml import etree
from pyvcloud.vcd.client import BasicLoginCredentials, Client

import os
import pprint
import random
import sys
from ipaddress import ip_address
from typing import TYPE_CHECKING, Dict, List, Union
from collections import OrderedDict

from requests.packages.urllib3 import disable_warnings

disable_warnings()

def plxml(xml):
    print(etree.tostring(xml, pretty_print=True).decode('utf-8'))

print('Hosts:')
host_list = [
    'https://daldir01.vmware-solutions.cloud.ibm.com',
    'https://fradir01.vmware-solutions.cloud.ibm.com',
    'https://sdaldir01.vmware-solutions.cloud.ibm.com',
    'https://ssao01dir01.vmware-solutions.cloud.ibm.com'
]
for index in range(len(host_list)):
    print(f'{index+1}: {host_list[index]}')
number = int(input("Which host do you want to connect to:"))
host = host_list[number-1]
print()
sysusr = str(input("Enter your user id:"))
print()
syspwd = str(input("Enter your password:"))
print()
sysorg = 'System'

client = Client(host, verify_ssl_certs=False)
client.set_highest_supported_version()
client.set_credentials(BasicLoginCredentials(sysusr, sysorg, syspwd))
# added code from create_esg.py

# get admin users xml view of Director
admin_user_xml = client.get_admin()

def get_available_ips(
        network,
        available_ips: Dict[str, Dict[str, str]],
        network_name: str) -> Dict[str, Dict[str, str]]:
    """Get list of all possible ips in network."""
    if hasattr(network, 'IpRanges'):
        for iprange in getattr(network.IpRanges, 'IpRange', []):
            iprange_start = ip_address(str(iprange.StartAddress))
            iprange_end = ip_address(str(iprange.EndAddress))
            while iprange_start <= iprange_end:
                available_ips[network_name]['ips'].append(str(iprange_start))
                iprange_start += 1
    else:
        print(f'Unable to find IpRanges in network "{network_name}".')
    return available_ips

def get_provisioned_ips(
        network,
        provisioned_ips: Dict[str, Dict[str, str]],
        network_name: str) -> Dict[str, Dict[str, str]]:
    """Get list of all ips provisioned to ESGs in network."""
    if hasattr(network, 'SubAllocations'):
        for ip_allocation in getattr(network.SubAllocations, 'SubAllocation', []):
            suballoc_start = ip_address(
                str(ip_allocation.IpRanges.IpRange.StartAddress))
            suballoc_end = ip_address(
                str(ip_allocation.IpRanges.IpRange.EndAddress))
            while suballoc_start <= suballoc_end:
                provisioned_ips[network_name]['ips'].append(
                    str(suballoc_start))
                suballoc_start += 1
    else:
        print(f'Unable to find SubAllocations in network "{network_name}".')

    return provisioned_ips

def get_allocated_ips(
        network,
        allocated_ips: Dict[str, Dict[str, str]],
        network_name: str) -> Dict[str, Dict[str, str]]:
    """Get list of all ips allocated to resources in network."""
    if hasattr(network, 'AllocatedIpAddresses'):
        for allocatedip in getattr(network.AllocatedIpAddresses, 'IpAddress', []):
            alloc_start = ip_address(str(allocatedip))
            alloc_end = ip_address(str(allocatedip))
            while alloc_start <= alloc_end:
                allocated_ips[network_name]['ips'].append(str(alloc_start))
                alloc_start += 1
    else:
        #logger.info(f'Unable to find AllocatedIpAddresses in network "{network_name}".')
        print(
            f"Unable to find AllocatedIpAddresses in network '{network_name}'.")
    return allocated_ips

def main():
    # get list of ips provisioned to gateways
    available_ips = {}
    provisioned_ips = {}
    allocated_ips = {}
    external_networks = OrderedDict()

    for network_xml in admin_user_xml.Networks.Network:
        external_network = client.get_resource(network_xml.get('href'))
        for network in external_network.Configuration.IpScopes.IpScope:
            gateway = str(network.Gateway)
            network_name = str(network_xml.get('name'))
            external_networks[network_name] = None
            # ...
            provisioned_ips.update({network_name: {"ips": []}})
            available_ips.update(
                {network_name: {"ips": [], "gateway": gateway}})
            allocated_ips.update({network_name: {"ips": []}})
            provisioned_ips = get_provisioned_ips(
                network, provisioned_ips, network_name)
            available_ips = get_available_ips(
                network, available_ips, network_name)
            allocated_ips = get_allocated_ips(
                network, allocated_ips, network_name)
            for net_name, dicts in available_ips.items():
                ip_set = set(dicts['ips'])
                ip_set -= set(provisioned_ips[net_name]['ips'])
                ip_set -= set(allocated_ips[net_name]['ips'])
            available_ips[network_name]['ips'] = sorted(ip_set, key=ip_address)

    # New code to output IPs
    pp = pprint.PrettyPrinter(indent=4)
    external_networks = list(external_networks.keys())
    for index in range(len(external_networks)):
        print(f'{index+1}: {external_networks[index]}')
    print()
    number = int(
        input(f'Which network do you want to see: [1-{len(external_networks)}]:'))
    print()
    if number <= len(external_networks) and number > 0:
        print(external_networks[number - 1])
        pp.pprint(available_ips[external_networks[number - 1]])

if __name__ == '__main__':
    main()
