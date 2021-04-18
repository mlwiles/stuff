"""
script: device_bios_report.py
description: gets list of all accessible bare metal machines - gets current bios version and available version for update
author: Mike Wiless
version: 0.1
date: 09/19/19

python device_bios_report.py
Enter SoftLayer account credentials
Username: 
API Key (input won't display):

Pick a license from above by entering the line number (0-61): 59
Number of licenses to order: 3
Ordering 3 x vRealize Network Insight 3 Advance - 4 CPU for $522/month, are you sure you want to place the order? (yes/y to confirm): y
Order placed, order ID is 40436213, order date is 2019-05-29T06:28:27-06:00, waiting 5 seconds for order to complete...
Waiting another 5 seconds for order to complete...
Licenses ready at 2019-05-29T06:28:39-06:00, billing IDs are: [redacted, redacted, redacted]
License keys: ['redacted', 'redacted', 'redacted']

Order another license? (yes/y to confirm): n
"""
import getpass
import string
import sys
import time
import SoftLayer

# SL ACCOUNT
# API_KEY_HERE
# https://sldn.softlayer.com/python/get_server_details.py

"""
https://softlayer-api-python-client.readthedocs.io/en/latest/api/managers/hardware/
	object_mask = "mask[id]"
	devices = mgr.list_hardware(mask=object_mask)
	{
	  "datacenter": {
	    "statusId": 2,
	    "id": 983497,
	    "name": "sao01",
	    "longName": "Sao Paulo 1"
	  },
	  "domain": "ssao01m01.st.dir",
	  "memoryCapacity": 192,
	  "hostname": "sao01gw02",
	  "hardwareStatusId": 5,
	  "primaryIpAddress": "169.57.183.67",
	  "processorPhysicalCoreAmount": 28,
	  "globalIdentifier": "54491411-06b2-4447-9d28-c24e6c9f0e85",
	  "primaryBackendIpAddress": "10.150.82.78",
	  "id": 1644315,
	  "fullyQualifiedDomainName": "sao01gw02.ssao01m01.st.dir"
	}

https://softlayer-api-python-client.readthedocs.io/en/latest/api/managers/hardware/
	get_hardware(hardware_id, **kwargs)

BIOS
"hardwareComponentModelId": 2367,
BIOS	3.0a 1-11-2019	3.1 8-27-2019
3.0a 1-11-2019 : 108305
3.1 8-27-2019 : 161436 ("isQualified": 1)

SoftLayer_Hardware_Server::getComponents =>SoftLayer_Hardware_Component

SoftLayer_Hardware_Component.hardwareComponentModel => SoftLayer_Hardware_Component_Model
https://sldn.softlayer.com/reference/datatypes/SoftLayer_Hardware_Component_Model/
"""

def connect():
	# prompt for credentials
	print "Enter SoftLayer account credentials"
	sl_username = "ACCOUNT_NAME"#string.strip(raw_input("Username: "))
	sl_apikey = "API_KEY"#string.strip(getpass.getpass("API Key (input won't display): "))

	return SoftLayer.Client(username=sl_username, api_key=sl_apikey)


def getdevicebios(client):
	# get hardware manager - https://softlayer-api-python-client.readthedocs.io/en/latest/api/managers/hardware/
   mgr = SoftLayer.HardwareManager(client)
   # https://sldn.softlayer.com/python/get_device_configuration_upgrade.py/
   hardware_service = client['SoftLayer_Hardware_Server']
   hardware = client['SoftLayer_Hardware']
   #list_hardware(tags=None, cpus=None, memory=None, hostname=None, domain=None, datacenter=None, nic_speed=None, public_ip=None, private_ip=None, **kwargs)
   list_mask = "mask[id]"
   devices = mgr.list_hardware(mask=list_mask)
   for device in devices:
   	print device
   	hardware = mgr.get_hardware(device['id'])
   	print hardware
   	print "%s(%s) %s" % (hardware['hostname'],hardware['id'],hardware['primaryIpAddress'])
   	#server = hardware.getComponents(hardware['id'])
   	
	#dev = device['item']
	#print "%s" % (dev['name'])
	#print "%s   %s - %s %s" % (i, dev['description'], dev['capacity'], dev['units'])
	#i += 1

	print "License options available:"
	list.sort(options, key=lambda x: x['item']['description'])
	i = 0
	for opt in options:
		o = opt['item']
		print "%s   %s - %s %s" % (i, o['description'], o['capacity'], o['units'])
		i += 1
	assert i == num_options

	# promt for license to order
	option_index = int(string.strip(raw_input("Pick a license from above by entering the line number (0-%s): " % (num_options-1))))
	assert option_index in range(0, num_options)
	option_selected = options[option_index]
	license_price_id = option_selected['id']

	# prompt for quantity
	quantity = int(string.strip(raw_input("Number of licenses to order: ")))

	# build order info
	order_info = {'complexType': 'SoftLayer_Container_Product_Order_Software_License',
				  'quantity': quantity,
				  'packageId': 301,
				  'prices': [{'id': license_price_id}]}

	# validate order information
	result = client['Product_Order'].verifyOrder(order_info)
	result_item = result['prices'][0]['item']
	order_prompt = "Ordering %s x %s - %s %s for $%s/month, are you sure you want to place the order? (yes/y to confirm): " % \
				   (result['quantity'], result_item['description'], result_item['capacity'], result_item['units'], result['postTaxRecurringMonthly'])
	place_order = string.strip(raw_input(order_prompt)).lower()
	if place_order not in ['y', 'yes']:
		print "Order cancelled."
		return

	# place license order
	result = client['Product_Order'].placeOrder(order_info)
	order_id = result['orderId']
	print "Order placed, order ID is %s, order date is %s, waiting 5 seconds for order to complete..." % (order_id, result['orderDate'])
	time.sleep(5)

	# wait until order is approved
	order_approved = False
	while not order_approved:
		billing_info = client.call('Billing_Order', 'getObject', id=order_id, mask='mask[orderTopLevelItems.billingItem.id]')
		if billing_info['status'].lower() == 'approved':
			order_approved = True
		else:
			print "Waiting another 5 seconds for order to complete..."
			time.sleep(5)

	# get billing items
	billing_ids = []
	for order_item in billing_info['orderTopLevelItems']:
		if order_item.get('billingItem', {}).get('id'):
			billing_ids.append(order_item['billingItem']['id'])
	print "Licenses ready at %s, billing IDs are: %s" % (billing_info['modifyDate'], billing_ids)
	assert quantity == len(billing_ids)

	# print license keys
	licenses = client.call('Software_AccountLicense', 'getAllObjects', mask='billingItem')
	license_keys = []
	for license in licenses:
		if license.get('billingItem', {}).get('id') in billing_ids:
			license_keys.append(license['key'])
	print "License keys: %s" % license_keys
	assert quantity == len(license_keys)

	# end
	print ""
"""
if __name__ == "__main__":
	client = connect()
	getdevicebios(client)
