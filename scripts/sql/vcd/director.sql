--finds any logical resource that does not exist in the pvdc
select * from vdc_logical_resource where prov_vdc_lr_id not in (select id from prov_vdc_logical_resource) order by prov_vdc_lr_id
--gets additional information ^^
select name from org_prov_vdc where id in (select vdc_id from vdc_logical_resource where prov_vdc_lr_id not in (select id from prov_vdc_logical_resource))