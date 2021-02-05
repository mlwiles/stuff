####################### vcloud director access variables #######################
vcd_user         = "REPLACE_VCD_USER_HERE"
vcd_password     = "REPLACE_VCD_PASSWORD_HERE"
vcd_logging      = true
vcd_logging_file = "/tmp/vcd_terraform.log"

####################### virtual datacenter variables #######################
vdc_org_name              = "REPLACE_VCD_ORG_NAME_HERE" 
vdc_name                  = "REPLACE_VCD_NAME_HERE"
vdc_edge_gateway          = "REPLACE_VCD_EDGE_GATEWAY_HERE"
vdc_external_network_name = "REPLACE_VCD_EXTERNAL_NETWORK_NAME_HERE"
vdc_service_network_name  = "REPLACE_VCD_SERVICE_NETWORK_NAME_HERE"
vdc_whitelist_address     = "REPLACE_VCD_WHITELIST_ADDRESS_HERE"
vdc_edge_external_address = "REPLACE_VCD_EDGE_EXTERNAL_ADDRESS_HERE"
vdc_edge_service_address  = "REPLACE_VCD_EDGE_SERVICE_ADDRESS_HERE"

####################### virtual machine template #######################
vdc_catalog_name = "REPLACE_VCD_CATALOG_NAME_HERE"

####################### virtual machine #######################
vm_metadata_creator = "REPLACE_VM_METADATA_CREATOR_HERE"
vm_metadata_version = "REPLACE_VM_METADATA_VERSION_HERE"
vm_metadata_date    = "REPLACE_VM_METADATA_DATE_HERE"
vm_power_on         = true

####################### virtual machine customization #######################
vm_customization_redhat_activation_key               = "REPLACE_VM_CUSTOMIZATION_REHDAT_ACTIVATION_KEY_HERE"
vm_customization_auto_generate_password              = false
vm_customization_admin_password                      = "REPLACE_VM_CUSTOMIZATION_ADMIN_PASSWORD_HERE"
vm_customization_must_change_password_on_first_login = false

####################### vcd routed network #######################
vcd_network_routed_name                         = "REPLACE_VCD_NETWORK_ROUTED_NAME_HERE"
vcd_network_routed_gateway                      = "REPLACE_VCD_NETWORK_ROUTED_GATEWAY_HERE"
vcd_network_routed_netmask                      = "REPLACE_VCD_NETWORK_ROUTED_NETMASK_HERE"
vcd_network_routed_static_ip_pool_start_address = "REPLACE_VCD_NETWORK_ROUTED_STATIC_IP_POOL_START_ADDRESS_HERE"
vcd_network_routed_static_ip_pool_end_address   = "REPLACE_VCD_NETWORK_ROUTED_STATIC_IP_POOL_END_ADDRESS_HERE"
vcd_network_routed_network_definition           = "REPLACE_VCD_NETWORK_ROUTED_NETWORK_DEFINITION_HERE"

####################### vm network #######################