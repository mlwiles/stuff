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
vdc_catalog_name = "template-curation local catalog"
vdc_catalog_name = "REPLACE_VCD_CATALOG_NAME_HERE"

####################### virtual machine #######################
vm_metadata_creator = "IBM VMWare Solutions"
vm_metadata_version = "v.automation-test"
vm_metadata_date    = "REPLACE_VM_METADATA_DATE_HERE"
vm_power_on         = true

####################### virtual machine customization #######################
vm_customization_redhat_activation_key               = "REPLACE_VM_CUSTOMIZATION_REHDAT_ACTIVATION_KEY_HERE"
vm_customization_auto_generate_password              = false
vm_customization_admin_password                      = "REPLACE_VM_CUSTOMIZATION_ADMIN_PASSWORD_HERE"
vm_customization_must_change_password_on_first_login = false

####################### vcd routed network #######################
vcd_network_routed_name                         = "template-test-network"
vcd_network_routed_gateway                      = "192.168.20.1"
vcd_network_routed_netmask                      = "255.255.255.0"
vcd_network_routed_static_ip_pool_start_address = "192.168.20.2"
vcd_network_routed_static_ip_pool_end_address   = "192.168.20.100"
vcd_network_routed_network_definition           = "192.168.20.1/24"

####################### vm network #######################