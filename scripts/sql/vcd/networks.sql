select * from logical_network where name = 'template-test1-network'
select * from logical_network where name = 'template-test-network'
select * from logical_network where scope_id = '537027f0-1dc3-4eac-900e-061a46110fb2'
delete from logical_network where name = 'template-test-network'

select * from gateway_interface where logical_network_id = '6f4f81a8-9b2b-48f0-b132-71ae960584a5'
delete from gateway_interface where logical_network_id = '6f4f81a8-9b2b-48f0-b132-71ae960584a5'

select * from gateway_assigned_ip where gateway_interface_id = '4ed1754a-5097-4a7e-8f1e-fc8c3c1c4be0'
delete from gateway_assigned_ip where gateway_interface_id = '4ed1754a-5097-4a7e-8f1e-fc8c3c1c4be0'

--------
select * from logical_network_ip_scope where scope_id = '537027f0-1dc3-4eac-900e-061a46110fb2'
select * from logical_network_ip_scope where scope_id in (select id from ip_scope where gateway = '192.168.20.1' and dns1 = '161.26.0.10')

delete from ip_scope where gateway = '192.168.20.1' and dns1 = '161.26.0.10'
delete from ip_range where scope_id in (select id from ip_scope where gateway = '192.168.20.1' and dns1 = '161.26.0.10')

delete from real_network where name like '%template-test-network%'
delete from real_network_backing where rnet_id = 'e943b66b-e4cc-4065-ad88-c6bfd033ef0f'

select * from gateway_interface where logical_network_id = '6f4f81a8-9b2b-48f0-b132-71ae960584a5'
delete from vapp_logical_resource where name = 'template-test-network'

delete from vdc_logical_resource where name = 'template-test-network'

----------------------------------------------------------------------

select * from real_network where name like '%template-test-network%'

"id"	"name"	"pool_id"	"portgroup_moref"	"logical_switch_id"	"portgroup_type"	"vc_id"	"state"	"creation_time"	"nsxt_manager_id"
"e943b66b-e4cc-4065-ad88-c6bfd033ef0f"	"dvs.VCDVStemplate-test-network-6f4f81a8-9b2b-48f0-b132-71ae960584a5"	"5f96a55f-a9c2-4759-8435-31fb03519439"		"virtualwire-315225"	"VIRTUAL_WIRE"	"2642bc0d-a97e-463b-bbf5-e1f2f0162dac"	0	"2021-05-24 17:11:02.531"

select * from vapp_logical_resource where name = 'template-test-network'

"id"	"vapp_id"	"fo_handle_id"	"lr_type"	"fo_id"	"name"	"version_number"
"d3d103ec-d313-49f0-ac5c-4ce25bdaa8ad"	"cf1cbc8b-0b82-4240-b443-eb0bfc768e04"	"3a73c259-2263-4586-bbb4-1b3e7b05c064"	"NETWORK"	"2f1057e9-bd32-41da-9039-f6c739a111d8"	"template-test-network"	1
"8ff39ca5-ba90-434d-940f-ccf05e18fd81"	"97489e80-77d4-479c-b6a6-cbda3b648e17"	"39abd0d4-100e-45ea-bebd-dd59416c8e63"	"NETWORK"	"21850c1f-2f1a-4571-8c10-46629fb7c77e"	"template-test-network"	1	