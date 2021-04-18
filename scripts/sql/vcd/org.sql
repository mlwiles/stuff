delete from org_member_source where org_id = '35049045-81da-495c-b550-ad26671da72f';
delete from org_member where org_id = '35049045-81da-495c-b550-ad26671da72f';
delete from universal_routing_config where router_id in (select router_id from vdc_group_router_egress where vdc_group_org_vdc_id in (select id from vdc_group_org_vdc where org_id = '35049045-81da-495c-b550-ad26671da72f'));
delete from vdc_group_router_egress where vdc_group_org_vdc_id in (select id from vdc_group_org_vdc where org_id = '35049045-81da-495c-b550-ad26671da72f');
delete from vdc_group_org_vdc where org_id = '35049045-81da-495c-b550-ad26671da72f';
delete from vdc_group_logical_resource where org_id = '35049045-81da-495c-b550-ad26671da72f';
delete from organization where org_id = '35049045-81da-495c-b550-ad26671da72f';
