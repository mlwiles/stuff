# Suggestions:
# To get a more verbose log, run the following:
# export TF_LOG=TRACE;export TF_LOG_PATH="/tmp/terraform.log"

# Requirements:
# vDC created with sufficient resources

# Helpful Links:
# https://www.sysadmintutorials.com/getting-started-terraform-vmware-vcloud-director/
# https://blogs.vmware.com/cloudprovider/2019/11/terraform-vcloud-director-provider-v2-5-0-features.html
# https://github.com/vmware/go-vcloud-director
# https://www.terraform.io/docs/

####################### VCD #######################
# https://www.terraform.io/docs/providers/vcd/index.html
provider "vcd" {
  user                 = var.vcd_user
  password             = var.vcd_password
  auth_type            = var.vcd_auth_type
  org                  = var.vdc_org_name
  vdc                  = var.vdc_name
  url                  = var.vcd_url
  max_retry_timeout    = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
  logging              = var.vcd_logging
  logging_file         = var.vcd_logging_file
}

####################### NETWORKS #######################
# https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/network_routed
resource "vcd_network_routed" "template-test-network" {
  name            = var.vcd_network_routed_name
  edge_gateway    = var.vdc_edge_gateway
  gateway         = var.vcd_network_routed_gateway
  netmask         = var.vcd_network_routed_netmask
  interface_type  = var.vcd_network_routed_interface_type
  static_ip_pool {
    start_address = var.vcd_network_routed_static_ip_pool_start_address
    end_address   = var.vcd_network_routed_static_ip_pool_end_address
  }
  dns1            = var.vcd_network_routed_dns1
  dns2            = var.vcd_network_routed_dns2
}

####################### VAPPS #######################
# https://www.terraform.io/docs/providers/vcd/r/vapp.html
resource "vcd_vapp" "vapp-test-centos7" {
  name = "vapp-test-centos7"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}
resource "vcd_vapp" "vapp-test-centos8" {
  name = "vapp-test-centos8"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}
resource "vcd_vapp" "vapp-test-redhat7" {
  name = "vapp-test-redhat7"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}
resource "vcd_vapp" "vapp-test-redhat8" {
  name = "vapp-test-redhat8"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}
resource "vcd_vapp" "vapp-test-windows2016" {
  name = "vapp-test-windows2016"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}
resource "vcd_vapp" "vapp-test-windows2019" {
  name = "vapp-test-windows2019"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}

####################### VAPP NETWORKS #######################
resource "vcd_vapp_org_network" "vapp-net-test-centos7" {
  org              = var.vdc_org_name
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.vapp-test-centos7.name
  org_network_name = vcd_network_routed.template-test-network.name
}
resource "vcd_vapp_org_network" "vapp-net-test-centos8" {
  org              = var.vdc_org_name
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.vapp-test-centos8.name
  org_network_name = vcd_network_routed.template-test-network.name
}
resource "vcd_vapp_org_network" "vapp-net-test-redhat7" {
  org              = var.vdc_org_name
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.vapp-test-redhat7.name
  org_network_name = vcd_network_routed.template-test-network.name
}
resource "vcd_vapp_org_network" "vapp-net-test-redhat8" {
  org              = var.vdc_org_name
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.vapp-test-redhat8.name
  org_network_name = vcd_network_routed.template-test-network.name
}
resource "vcd_vapp_org_network" "vapp-net-test-windows2016" {
  org              = var.vdc_org_name
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.vapp-test-windows2016.name
  org_network_name = vcd_network_routed.template-test-network.name
}
resource "vcd_vapp_org_network" "vapp-net-test-windows2019" {
  org              = var.vdc_org_name
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.vapp-test-windows2019.name
  org_network_name = vcd_network_routed.template-test-network.name
}

####################### FIREWALL and DNAT RULES #######################
# https://www.terraform.io/docs/providers/vcd/r/nsxv_firewall_rule.html
# https://www.terraform.io/docs/providers/vcd/r/nsxv_dnat.html
####################### ALL VMs #######################
resource "vcd_nsxv_firewall_rule" "outbound-edge-test-firewall" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = "outbound"
  source { ip_addresses      = [var.vcd_network_routed_network_definition] }
  destination { ip_addresses = ["any"] }
  service {
    protocol                 = "any"
  }
}
resource "vcd_nsxv_snat" "outbound-edge-snat-test-service" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_service_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = "outbound service network"
  original_address   = var.vcd_network_routed_network_definition
  translated_address = var.vdc_edge_service_address
}
resource "vcd_nsxv_snat" "outbound-edge-snat-test-tenant-external" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = "outbound public internet"
  original_address   = var.vcd_network_routed_network_definition
  translated_address = var.vdc_edge_external_address
}
####################### CENTOS7 #######################
resource "vcd_nsxv_firewall_rule" "vm-test-centos7-edge-firewall-inbound-ssh" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = format("%s inbound ssh",vcd_vapp_vm.vm-test-centos7.name)
  source { ip_addresses      = [var.vdc_whitelist_address] }
  destination { ip_addresses = [var.vdc_edge_external_address] }
  service {
    protocol                 = "tcp"
    port 	                   = "22230"
    source_port              = "any"
  }
}
resource "vcd_nsxv_dnat" "vm-test-centos7-edge-dnat-ssh" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = format("%s inbound ssh",vcd_vapp_vm.vm-test-centos7.name)
  original_address   = var.vdc_edge_external_address
  original_port      = "22230"
  translated_address = vcd_vapp_vm.vm-test-centos7.network.0.ip
  translated_port    = "22"
  protocol           = "tcp"
}
####################### CENTOS8 #######################
resource "vcd_nsxv_firewall_rule" "vm-test-centos8-edge-firewall-inbound-ssh" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = format("%s inbound ssh",vcd_vapp_vm.vm-test-centos8.name)
  source { ip_addresses      = [var.vdc_whitelist_address] }
  destination { ip_addresses = [var.vdc_edge_external_address] }
  service {
    protocol                 = "tcp"
    port 	                   = "22231"
    source_port              = "any"
  }
}
resource "vcd_nsxv_dnat" "vm-test-centos8-edge-dnat-ssh" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = format("%s inbound ssh",vcd_vapp_vm.vm-test-centos8.name)
  original_address   = var.vdc_edge_external_address
  original_port      = "22231"
  translated_address = vcd_vapp_vm.vm-test-centos8.network.0.ip
  translated_port    = "22"
  protocol           = "tcp"
}
####################### REDHAT7 #######################
resource "vcd_nsxv_firewall_rule" "vm-test-redhat7-edge-firewall-inbound-ssh" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = format("%s inbound ssh",vcd_vapp_vm.vm-test-redhat7.name)
  source { ip_addresses      = [var.vdc_whitelist_address] }
  destination { ip_addresses = [var.vdc_edge_external_address] }
  service {
    protocol                 = "tcp"
    port 	                   = "22232"
    source_port              = "any"
  }
}
resource "vcd_nsxv_dnat" "vm-test-redhat7-edge-dnat-ssh" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = format("%s inbound ssh",vcd_vapp_vm.vm-test-redhat7.name)
  original_address   = var.vdc_edge_external_address
  original_port      = "22232"
  translated_address = vcd_vapp_vm.vm-test-redhat7.network.0.ip
  translated_port    = "22"
  protocol           = "tcp"
}
####################### REDHAT8 #######################
resource "vcd_nsxv_firewall_rule" "vm-test-redhat8-edge-firewall-inbound-ssh" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = format("%s inbound ssh",vcd_vapp_vm.vm-test-redhat8.name)
  source { ip_addresses      = [var.vdc_whitelist_address] }
  destination { ip_addresses = [var.vdc_edge_external_address] }
  service {
    protocol                 = "tcp"
    port 	                   = "22233"
    source_port              = "any"
  }
}
resource "vcd_nsxv_dnat" "vm-test-redhat8-edge-dnat-ssh" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = format("%s inbound ssh",vcd_vapp_vm.vm-test-redhat8.name)
  original_address   = var.vdc_edge_external_address
  original_port      = "22233"
  translated_address = vcd_vapp_vm.vm-test-redhat8.network.0.ip
  translated_port    = "22"
  protocol           = "tcp"
}
####################### WINDOWS2016 #######################
resource "vcd_nsxv_firewall_rule" "vm-test-windows2016-edge-firewall-inbound-rdp" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = format("%s inbound rdp",vcd_vapp_vm.vm-test-windows2016.name)
  source { ip_addresses      = [var.vdc_whitelist_address] }
  destination { ip_addresses = [var.vdc_edge_external_address] }
  service {
    protocol                 = "tcp"
    port 	                   = "34890"
    source_port              = "any"
  }
}
resource "vcd_nsxv_dnat" "vm-test-windows2016-edge-dnat-rdp" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = format("%s inbound rdp",vcd_vapp_vm.vm-test-windows2016.name)
  original_address   = var.vdc_edge_external_address
  original_port      = "34890"
  translated_address = vcd_vapp_vm.vm-test-windows2016.network.0.ip
  translated_port    = "3389"
  protocol           = "tcp"
}
####################### WINDOWS2019 #######################
resource "vcd_nsxv_firewall_rule" "vm-test-windows2019-edge-firewall-inbound-rdp" {
  org 		                   = var.vdc_org_name
  vdc 		                   = var.vdc_name
  edge_gateway 	             = var.vdc_edge_gateway
  name 		                   = format("%s inbound rdp",vcd_vapp_vm.vm-test-windows2019.name)
  source { ip_addresses      = [var.vdc_whitelist_address] }
  destination { ip_addresses = [var.vdc_edge_external_address] }
  service {
    protocol                 = "tcp"
    port 	                   = "34891"
    source_port              = "any"
  }
}
resource "vcd_nsxv_dnat" "vm-test-windows2019-edge-dnat-rdp" {
  org 		           = var.vdc_org_name
  vdc 		           = var.vdc_name
  edge_gateway 	     = var.vdc_edge_gateway
  network_name       = var.vdc_external_network_name
  network_type       = "ext"
  enabled            = true
  logging_enabled    = false
  description        = format("%s inbound rdp",vcd_vapp_vm.vm-test-windows2019.name)
  original_address   = var.vdc_edge_external_address
  original_port      = "34891"
  translated_address = vcd_vapp_vm.vm-test-windows2019.network.0.ip
  translated_port    = "3389"
  protocol           = "tcp"
}

####################### VIRTUAL MACHINES #######################
# https://www.terraform.io/docs/providers/vcd/r/vapp_vm.html
####################### CENTOS7 #######################
resource "vcd_vapp_vm" "vm-test-centos7" {
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-test-centos7.name
  name                                  = "vm-test-centos7"
  computer_name                         = "vm-test-centos7"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  guest_properties = {
    "guest.hostname" = "vm-test-centos7"
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  network {
    type                                = var.vm_network_type
    name                                = vcd_vapp_org_network.vapp-net-test-centos7.org_network_name
    ip_allocation_mode                  = var.vm_network_ip_allocation_mode
    ip                                  = "192.168.20.10"
    is_primary                          = var.vm_network_is_primary
    adapter_type                        = var.vm_network_adapter_type
  }
  catalog_name                          = var.vdc_catalog_name
  template_name                         = var.vm_template_name
  power_on                              = var.vm_power_on
}
####################### CENTOS8 #######################
resource "vcd_vapp_vm" "vm-test-centos8" {
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-test-centos8.name
  name                                  = "vm-test-centos8"
  computer_name                         = "vm-test-centos8"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  guest_properties = {
    "guest.hostname" = "vm-test-centos8"
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  network {
    type                                = var.vm_network_type
    name                                = vcd_vapp_org_network.vapp-net-test-centos8.org_network_name
    ip_allocation_mode                  = var.vm_network_ip_allocation_mode
    ip                                  = "192.168.20.11"
    is_primary                          = var.vm_network_is_primary
    adapter_type                        = var.vm_network_adapter_type
  }
  catalog_name                          = var.vdc_catalog_name
  template_name                         = "CentOS-8-Template-Official"
  power_on                              = var.vm_power_on
}
####################### REDHAT7 #######################
resource "vcd_vapp_vm" "vm-test-redhat7" {
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-test-redhat7.name
  name                                  = "vm-test-redhat7"
  computer_name                         = "vm-test-redhat7"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  guest_properties = {
    "guest.hostname" = "vm-test-redhat7"
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  network {
    type                                = var.vm_network_type
    name                                = vcd_vapp_org_network.vapp-net-test-redhat7.org_network_name
    ip_allocation_mode                  = var.vm_network_ip_allocation_mode
    ip                                  = "192.168.20.12"
    is_primary                          = var.vm_network_is_primary
    adapter_type                        = var.vm_network_adapter_type
  }
  catalog_name                          = var.vdc_catalog_name
  template_name                         = "RedHat-7-Template-Official"
  power_on                              = var.vm_power_on
}
####################### REDHAT8 #######################
resource "vcd_vapp_vm" "vm-test-redhat8" {
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-test-redhat8.name
  name                                  = "vm-test-redhat8"
  computer_name                         = "vm-test-redhat8"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  guest_properties = {
    "guest.hostname" = "vm-test-redhat8"
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  network {
    type                                = var.vm_network_type
    name                                = vcd_vapp_org_network.vapp-net-test-redhat8.org_network_name
    ip_allocation_mode                  = var.vm_network_ip_allocation_mode
    ip                                  = "192.168.20.13"
    is_primary                          = var.vm_network_is_primary
    adapter_type                        = var.vm_network_adapter_type
  }
  catalog_name                          = var.vdc_catalog_name
  template_name                         = "RedHat-8-Template-Official"
  power_on                              = var.vm_power_on
}
####################### WINDOWS2016 #######################
resource "vcd_vapp_vm" "vm-test-windows2016" {
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-test-windows2016.name
  name                                  = "vm-test-windows2016"
  computer_name                         = "vm-test-win2016"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  guest_properties = {
    "guest.hostname" = "vm-test-windows2016"
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  network {
    type                                = var.vm_network_type
    name                                = vcd_vapp_org_network.vapp-net-test-windows2016.org_network_name
    ip_allocation_mode                  = var.vm_network_ip_allocation_mode
    ip                                  = "192.168.20.14"
    is_primary                          = var.vm_network_is_primary
    adapter_type                        = var.vm_network_adapter_type
  }
  catalog_name                          = var.vdc_catalog_name
  template_name                         = "Windows-2016-Template-Official"
  power_on                              = var.vm_power_on
}
####################### WINDOWS2019 #######################
resource "vcd_vapp_vm" "vm-test-windows2019" {
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-test-windows2019.name
  name                                  = "vm-test-windows2019"
  computer_name                         = "vm-test-win2019"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  guest_properties = {
    "guest.hostname" = "vm-test-windows2019"
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  network {
    type                                = var.vm_network_type
    name                                = vcd_vapp_org_network.vapp-net-test-windows2019.org_network_name
    ip_allocation_mode                  = var.vm_network_ip_allocation_mode
    ip                                  = "192.168.20.15"
    is_primary                          = var.vm_network_is_primary
    adapter_type                        = var.vm_network_adapter_type
  }
  catalog_name                          = var.vdc_catalog_name
  template_name                         = "Windows-2019-Template-Official"
  power_on                              = var.vm_power_on
}