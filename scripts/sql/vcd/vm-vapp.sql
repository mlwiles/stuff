--select * from vcloud.dbo.org_prov_vdc where name like '%Veeam%' or name like '%Public%'
--select * from vcloud.dbo.organization where display_name like '%mwiles%' or name like '%Public%'

select * from vapp_vm_disk_storage_class where vapp_vm_id = (select id from vapp_vm where name = '2285-win2019')select * from vapp_vm_sclass_metrics where vapp_vm_id = (select id from vapp_vm where name = '2285-win2019')
--delete from vapp_vm_sclass_metrics where vapp_vm_id = (select id from vapp_vm where name = '2285-win2019')

select * from vapp_eula where vm_id = (select id from vapp_vm where name = '2285-win2019')
select * from vapp_eula where sg_id =  (select sg_id from vm_container where name = 'testing-2285')
select * from vapp_product_info where vm_id = (select id from vapp_vm where name = '2285-win2019')
select * from vapp_product_info where sg_id = (select sg_id from vm_container where name = 'testing-2285')
select * from vapp_logical_resource where vapp_id = (select sg_id  from vm_container where name = 'testing-2285')
select * from vapp_property where pi_id = (select id from vapp_product_info where vm_id = (select id  from vapp_vm where name = '2285-win2019'))
select * from guest_personalization_info where vapp_vm_id = (select id from vapp_vm where name = '2285-win2019')
select * from vm_gosc_status where vapp_vm_id = (select id from vapp_vm where name = '2285-win2019')
--delete from vm_gosc_status where vapp_vm_id = (select id from vapp_vm where name = '2285-win2019')
select * from vm_dstore_metrics_inv where vm_inv_id = (select instance_uuid from vm where name = '2285-win2019')select * from deployed_vm where vm_id in (select id from vm where name = '2285-win2019')
select * from deployed_vm_resource where vm_id in (select id from vm where name = '2285-win2019')
select * from resource_item where resource_id = (select resource_id from deployed_vm_resource where vm_id in (select id from vm where name = '2285-win2019'))
select * from vm_disk_storage_class where vm_id = (select id from vm where name = '2285-win2019')
select * from vm_disk where vm_id = (select id from vm where name = '2285-win2019')


select * from vm_resource where vm_id = (select id from vm where name = '2285-win2019')


select * from vm where name = '2285-win2019'
select * from vapp_vm where name = '2285-win2019'
select * from vm where name = '2285-win2016'
select * from vapp_vm where name = '2285-win2016'
select * from vm_container where name = 'testing-2285'

delete from vm where name = '2285-win2019'
delete from vapp_vm where name = '2285-win2019'
delete from vm where name = '2285-win2016'
delete from vapp_vm where name = '2285-win2016'
delete from vm_container where name = 'testing-2285'

vapp - vm - gb-test-2437
vapp - vm - gbtestvm1-2437-71
vapp - vm - gbtestvm1-2437-c1

/* 
vAPP_VM is the VM name
VM_CONTAINER is the vAPP name
*/
DECLARE @VAPP_VM	nvarchar(100)
DECLARE @VM_CONTAINER nvarchar(100)
SET @VM_CONTAINER = 'win2019'
SET @VAPP_VM = 'VM2019Win'
select * from vm where name = @VAPP_VM
select * from vapp_vm where name = @VAPP_VM
select * from  vm_container where name = @VM_CONTAINER
/* single selection */ 
/*
select * from vapp_vm_disk_storage_class where vapp_vm_id = (select id from vapp_vm where name = @VAPP_VM)
select * from vapp_vm_sclass_metrics where vapp_vm_id = (select id from vapp_vm where name = @VAPP_VM)
select * from vapp_eula where vm_id = (select id from vapp_vm where name = @VAPP_VM)
select * from vapp_eula where sg_id =  (select sg_id from vm_container where name =  @VM_CONTAINER)
select * from vapp_product_info where vm_id = (select id from vapp_vm where name = @VAPP_VM)
select * from vapp_product_info where sg_id = (select sg_id from vm_container where name =  @VM_CONTAINER)
select * from vapp_logical_resource where vapp_id = (select sg_id  from vm_container where name =  @VM_CONTAINER)
select * from vapp_property where pi_id = (select id from vapp_product_info where vm_id = (select id  from vapp_vm where name = @VAPP_VM))
select * from guest_personalization_info where vapp_vm_id = (select id from vapp_vm where name = @VAPP_VM)
select * from vm_gosc_status where vapp_vm_id = (select id from vapp_vm where name = @VAPP_VM)
select * from vm_dstore_metrics_inv where vm_inv_id = (select instance_uuid from vm where name = @VAPP_VM)
select * from deployed_vm where vm_id in (select id from vm where name = @VAPP_VM)
select * from deployed_vm_resource where vm_id in (select id from vm where name = @VAPP_VM)
select * from resource_item where resource_id = (select resource_id from deployed_vm_resource where vm_id in (select id from vm where name = @VAPP_VM))
select * from vm_disk_storage_class where vm_id = (select id from vm where name = @VAPP_VM)
select * from vm_disk where vm_id = (select id from vm where name = @VAPP_VM)
*/
/* 
Deletes
*/
/*
delete from vapp_vm_disk_storage_class where vapp_vm_id in (select id from vapp_vm where name like @VAPP_VM)
delete from vapp_vm_sclass_metrics where vapp_vm_id in (select id from vapp_vm where name like @VAPP_VM)
delete from vapp_eula where vm_id in (select id from vapp_vm where name like @VAPP_VM)
delete from vapp_eula where sg_id in (select sg_id from vm_container where name =  @VM_CONTAINER)
delete from vapp_product_info where vm_id in (select id from vapp_vm where name like @VAPP_VM)
delete from vapp_product_info where sg_id in (select sg_id from vm_container where name =  @VM_CONTAINER)
delete from vapp_logical_resource where vapp_id in (select sg_id  from vm_container where name =  @VM_CONTAINER)
delete from vapp_property where pi_id = (select id from vapp_product_info where vm_id in (select id  from vapp_vm where name like @VAPP_VM))
delete from guest_personalization_info where vapp_vm_id in (select id from vapp_vm where name like @VAPP_VM)
delete from vm_gosc_status where vapp_vm_id in (select id from vapp_vm where name like @VAPP_VM)
delete from vm_dstore_metrics_inv where vm_inv_id in (select instance_uuid from vm where name like @VAPP_VM)
delete from deployed_vm where vm_id in (select id from vm where name like @VAPP_VM)
delete from deployed_vm_resource where vm_id in (select id from vm where name like @VAPP_VM)
delete from resource_item where resource_id in (select resource_id from deployed_vm_resource where vm_id in (select id from vm where name like @VAPP_VM))
delete from vm_disk_storage_class where vm_id in (select id from vm where name like @VAPP_VM)
delete from vm_disk where vm_id in (select id from vm where name like @VAPP_VM)
delete from vm where name = @VAPP_VM
delete from vapp_vm where name = @VAPP_VM
delete from  vm_container where name = @VM_CONTAINER
*/

