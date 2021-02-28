####################### vcloud director access variables #######################
variable "vcd_user" {
  type = string
  description = "vdc organization admin user id"
  default = "admin"
}
variable "vcd_password" {
  type = string
  description = "vdc organization admin password"
  default = "my-passwd"
}
variable "vcd_auth_type" {
  type = string
  description = "authentication type of the connection"
  default = "integrated"
}
variable "vcd_url" {
  type = string
  description = "vdc base url of the vcloud server"
  default = "https://daldir01.vmware-solutions.cloud.ibm.com/api"
}
variable "vcd_max_retry_timeout" {
  type = number
  description = "Maximum number of retries to login"
  default = 10
}
variable "vcd_allow_unverified_ssl" {
  type = bool
  description = "allow SSL not verified"
  default = true
}
variable "vcd_logging" {
  type = bool
  description = "enable logging"
  default = false
}
variable "vcd_logging_file" {
  type = string
  description = "log file location"
  default = "/tmp/tf.log"
}

####################### virtual datacenter variables #######################
variable "vdc_org_name" {
  type = string
  description = "vdc organization name"
  default = "my-org"
}
variable "vdc_name" {
  type = string
  description = "vdc name"
  default = "my-vdc"
}
variable "vdc_edge_gateway" {
  type = string
  description = "vdc NSX edge service gateway"
  default = "my-edge"
}
variable "vdc_external_network_name" {
  type = string
  description = "vdc NSX external network name"
  default = "my-external-network"
}
variable "vdc_service_network_name" {
  type = string
  description = "vdc NSX service network name"
  default = "my-service-network"
}
variable "vdc_whitelist_address" {
  type = string
  description = "address to allow inbound traffic into the ESG"
  default = "1.1.1.1"
}
variable "vdc_edge_external_address" {
  type = string
  description = "address to allow outbound traffic from the ESG"
  default = "2.2.2.2"
}
variable "vdc_edge_service_address" {
  type = string
  description = "service address of ESG"
  default = "52.117.132.68"
}

####################### virtual machine template #######################
variable "vdc_catalog_name" {
  type = string
  description = "vdc local catalog"
  default = "my-local-catalog"
}
variable "vm_catalog_name" {
  type = string
  description = "catalog that is source of the vapp/vm templates"
  default = "Public Catalog"
}
variable "vm_template_name" {
  type = string
  description = "name of the vapp/vm templates"
  default = "CentOS-7-Template-Official"
}
####################### virtual machine variables #######################
variable "vm_storage_profile" {
  type = string
  description = "vdc local catalog"
  default = "Standard"
}
variable "vm_metadata_creator" {
  type = string
  description = ""
  default = "terraform"
}
variable "vm_metadata_version" { 
  type = string
  description = ""
  default = "1.0"
}
variable "vm_metadata_date" {
  type = string
  description = ""
  default = "07/04/1776"
}
variable "vm_memory" {
  type = number
  description = "amount of memory for the vm"
  default = 8192
}
variable "vm_cpus" {
  type = number
  description = "number of vCPUs for the vm"
  default = 2
}  
variable "vm_cpu_cores" {
  type = number
  description = "number of cores per socket for the vm"
  default = 1
}
variable "vm_power_on" {
  type = bool
  description = "state of vm power"
  default = false
}

####################### virtual machine customization #######################
variable "vm_customization_force" { 
  type = bool
  description = "To use OS Customization or not"
  default = true
}
variable "vm_customization_change_sid" { 
  type = bool
  description = "If using OS Customization, change SID?"
  default = true
}
variable "vm_customization_allow_local_admin_password" { 
  type = bool
  description = "If using OS Customization, allow password change?"
  default = true
}
variable "vm_customization_auto_generate_password" {
  type = bool
  description = "If using OS Customization, auto generate password?"
  default = true
}
variable "vm_customization_admin_password" {
  type = string
  description = "If using OS Customization, enable administrator password?"
  default = "my-os-customized-passwd"
}
variable "vm_customization_redhat_activation_key" {
  type = string
  description = "Red Hat activation team"
  default = ""
}
variable "vm_customization_must_change_password_on_first_login" {
  type = bool
  description = "If using OS Customization, force change password at first login?"
  default = true
}

####################### vcd routed network #######################
variable "vcd_network_routed_name" {
  type = string
  description = "name of the routed network"
  default = "my-network" 
}
variable "vcd_network_routed_gateway" {
  type = string
  description = "gateway address for routed network"
  default = "192.168.1.1" 
}
variable "vcd_network_routed_netmask" {
  type = string
  description = "subnet mask for routed network"
  default = "255.255.0.0" 
}
variable "vcd_network_routed_interface_type" {
  type = string
  description = "type of network: isolated, subinterface, distributed for routed network"
  default = "subinterface"
}
variable "vcd_network_routed_static_ip_pool_start_address" {
  type = string
  description = "start of IP pool for routed network"
  default = "192.168.1.100" 
}
variable "vcd_network_routed_static_ip_pool_end_address" {
  type = string
  description = "end of IP pool for routed network"
  default = "192.168.1.200" 
}
variable "vcd_network_routed_dns1" {
  type = string
  description = "primary DNS for routed network"
  default = "161.26.0.10" 
}
variable "vcd_network_routed_dns2" {
  type = string
  description = "secondary DNS for routed network"
  default = "161.26.0.11" 
}
variable "vcd_network_routed_network_definition" {
  type = string
  description = "definition of the routed network"
  default = "192.168.1.1/16" 
}

####################### vm network #######################
variable "vm_network_type" {
  type = string
  description = "type of network: none, org, shared"
  default = "org"
}
variable "vm_network_ip_allocation_mode" {
  type = string
  description = "type of ip allocation mode: NONE, DHCP, POOL, MANUAL"
  default = "MANUAL"
}
variable "vm_network_is_primary" {
  type = bool
  description = "will this be primary vNIC"
  default = true
}
variable "vm_network_adapter_type" {
  type = string
  description = "type if vNIC: E1000E, VMXNET3, VMXNET3VRDMA, SRIOVETHERNETCARD"
  default = "VMXNET3"
}