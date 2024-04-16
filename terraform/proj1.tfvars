resource_group_name   = "Azuredevops"
location              = "eastus"
location_abbreviation = "eus"
instance_count        = 4
environment           = "udacity"
application           = "proj1"
managed_disk_name     = "osdisk"
vm_root_username      = "thiennnt"
image_linux           = "/subscriptions/a4b11da3-2642-4ae2-b8e0-ba40545a13d6/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/image_linux_hello_world"
common_tags           = { CreatedBy = "Terraform", "Environment" = "Udacity", Application = "Proj1" }
nsg_inbounds_allow = [22, 80, 443]
