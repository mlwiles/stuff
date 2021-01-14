####################### vcloud director access variables #######################
vcd_user         = "REPLACE_VCD_USER_HERE"
vcd_password     = "REPLACE_VCD_PASSWORD_HERE"
vcd_logging      = true
vcd_logging_file = "/tmp/vcd_terraform.log"

####################### virtual datacenter variables #######################
vdc_org_name              = "REPLACE_VCD_ORG_NAME" 
vdc_name                  = "REPLACE_VCD_NAME"
vdc_edge_gateway          = "REPLACE_VCD_EDGE_GATEWAY"
vdc_external_network_name = "REPLACE_VCD_EXT_NETWORK_NAME"
vdc_service_network_name  = "REPLACE_VCD_SERVICE_NETWORK_NAME"
vdc_whitelist_address     = "REPLACE_VCD_WHITELIST_ADDR"
vdc_edge_external_address = "REPLACE_VCD_EDGE_EXT_ADDR"
vdc_edge_service_address  = "REPLACE_VCD_SERVICE_NETWORK_NAME"

####################### virtual machine template #######################
vdc_catalog_name = "REPLACE_VCD_CATALOG_NAME"

####################### virtual machine #######################
vm_metadata_creator = "REPLACE_VCD_METADATA_CREATOR"
vm_metadata_version = "REPLACE_VCD_METADATA_VERSION"
vm_metadata_date    = "REPLACE_VCD_METADATA_DATE"

####################### virtual machine customization #######################
vm_customization_auto_generate_password              = false
vm_customization_admin_password                      = "REPLACE_VM_CUSTOMIZATION_ADMIN_PWD"
vm_customization_initscript                          = "REPLACE_VM_CUSTOMIZATION_INITSCRIPT"
vm_customization_must_change_password_on_first_login = false

####################### vcd routed network #######################
vcd_network_routed_name                         = "REPLACE_VCD_ROUTED_NAME"
vcd_network_routed_gateway                      = "REPLACE_VCD_ROUTED_GATEWAY"
vcd_network_routed_netmask                      = "REPLACE_VCD_ROUTED_NETMASK"
vcd_network_routed_static_ip_pool_start_address = "REPLACE_VCD_ROUTED_STATIC_IP_START"
vcd_network_routed_static_ip_pool_end_address   = "REPLACE_VCD_ROUTED_STATIC_IP_END"
vcd_network_routed_network_definition           = "REPLACE_VCD_ROUTED_CIDR"

####################### vm network #######################