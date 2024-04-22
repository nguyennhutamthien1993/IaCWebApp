resource_group_name   = "Azuredevops"
location              = "eastus"
location_abbreviation = "eus"
instance_count        = 2
environment           = "udacity"
application           = "proj1"
managed_disk_name     = "osdisk"
vm_root_username      = "thiennnt"
image_linux           = "/subscriptions/a9ab978b-a5d4-42b1-a453-fe2690ceb40f/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/image_linux_hello_world_1"
common_tags           = { CreatedBy = "Terraform", "Environment" = "Udacity", Application = "Proj1" }
