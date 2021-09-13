-- https://vkernelblog.com/detaching-a-resource-pool-vcloud-director/
select * from computehub_set_computehub
select * from  prov_vdc_logical_resource where lr_type='COMPUTE_HUB_SET'
select * from prov_vdc

-- Find which one is "NOT PRIMARY in this case to remove"
--"id"	"computehub_set_id"	"computehub_id"	"is_primary"
--"cd23e21f-2055-44f4-8fff-d0dec01bca6e"	"5d21b0bb-2d97-406c-bfe4-7623b7e7e552"	"6ed6c822-0664-4330-a6ad-1bcac4ee296b"	true
--"a3dc87dd-d533-4450-82fe-cda997477ecd"	"13bacf33-fd19-47a0-9a57-8de2e37567b5"	"8c389277-d495-464f-a673-8572debd25c2"	true
--"bff04403-a9f2-464e-8041-61b782671cd0"	"13bacf33-fd19-47a0-9a57-8de2e37567b5"	"52f91f0d-7941-4466-97f9-63966d13e984"	false

select * from computevm where computehub_id='bff04403-a9f2-464e-8041-61b782671cd0'

--"id" "computehub_id" "vrp_id" "deployment_status" "memory_min_mb" "memory_configured_mb" "cpu_min_mhz" "num_vcpu" "vmmoref" "vc_id" "is_custom_compute_profile"
--"0f9cb3f4-558a-4cb7-8b74-7b61af5b17d8" "bff04403-a9f2-464e-8041-61b782671cd0" "0bb59a85-454b-459c-9026-3125a3a8d556" "UNDEPLOYED" 0 8192 0 2 "vm-414" "acf756e5-9504-48b2-b2ab-92a55cb4af0f" false
--"3826face-0a49-40c1-b46b-d49328e7889a" "bff04403-a9f2-464e-8041-61b782671cd0" "0bb59a85-454b-459c-9026-3125a3a8d556" "DEPLOYED" 0 512 0 2 "vm-2066" "acf756e5-9504-48b2-b2ab-92a55cb4af0f" false
--"07880f11-7aa0-4af3-9b79-e871ab83b2b9" "bff04403-a9f2-464e-8041-61b782671cd0" "0bb59a85-454b-459c-9026-3125a3a8d556" "DEPLOYED" 0 512 0 2 "vm-1925" "acf756e5-9504-48b2-b2ab-92a55cb4af0f" false

delete from computevm where computehub_id='bff04403-a9f2-464e-8041-61b782671cd0'

select * from vapp_vm where cvm_id='0f9cb3f4-558a-4cb7-8b74-7b61af5b17d8'
-- No VM's found ...