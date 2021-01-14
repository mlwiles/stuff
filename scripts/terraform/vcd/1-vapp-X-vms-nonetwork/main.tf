# Suggestions:
# To get a more verbose log, run the following:
# export TF_LOG=TRACE;export TF_LOG_PATH="/tmp/terraform.log"

# Requirements:
# vDC created with sufficient resources

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

####################### VAPPS #######################
# https://www.terraform.io/docs/providers/vcd/r/vapp.html
resource "vcd_vapp" "vapp-tf-vms" {
  name = "vapp-tf-vms"
  org  = var.vdc_org_name
  vdc  = var.vdc_name
}

####################### VIRTUAL MACHINES #######################
# https://www.terraform.io/docs/providers/vcd/r/vapp_vm.html
####################### VM-X #######################
resource "vcd_vapp_vm" "vm-tf" {
  count                                 = 2
  org                                   = var.vdc_org_name
  vdc                                   = var.vdc_name
  vapp_name                             = vcd_vapp.vapp-tf-vms.name
  name                                  = "vm-tf-vm${count.index}"
  memory                                = var.vm_memory
  cpus                                  = var.vm_cpus
  cpu_cores                             = var.vm_cpu_cores
  storage_profile                       = var.vm_storage_profile
  metadata = {
    creator                             = var.vm_metadata_creator
    version                             = var.vm_metadata_version
    date                                = var.vm_metadata_date
  }
  customization {
    force                               = var.vm_customization_force
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
  }
  catalog_name                          = var.vm_catalog_name
  template_name                         = var.vm_template_name
  power_on                              = var.vm_power_on
}
