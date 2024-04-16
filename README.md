## Project Overview

In this project, you'll have the opportunity to demonstrate the skills you've learned in this course, by creating infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.

### Project Tasks

* Create and Apply a Tagging Policy
* Create a Server Image
* Create the infrastructure
* Deploying Your Infrastructure

## Setup the Environment

* Download and install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
* Download and add [Packer](https://developer.hashicorp.com/packer/install) to environment path
* Run cmd `packer plugins install github.com/hashicorp/azure` to install Azure Provider plugin for packer
* Download and add [Terraform](https://developer.hashicorp.com/terraform/install) to environment path 
* Login browser with azure portal account
* Run cmd `az login` to keep authorized session in prompt

## Implementing task `Create and Apply a Tagging Policy`
* Create file ![tagging-policy.json](./policy/tagging-policy.json) to define password required policy
* Run cmd `az policy definition create --name tagging-policy --rules policy/tagging-policy.json` to create policy
* Run cmd `az policy assignment create --policy tagging-policy` to assign policy in our subscription

## Implementing task `Create a Server Image`
* Create file ![server.json](./packer/server.json) to define linux image 
* Run cmd `packer build packer/server.json` to create an image from template.
    Remember to change your account information in variables section of template

## Implementing task `Create the infrastructure`
* Create file [main.tf](./terraform/main.tf) to define infrastructures as code 
* Create file [vars.tf](./terraform/vars.tf) to define all varibles you can use for each application, environment, location infrastructure
* Create var file [proj1.tfvars](./terraform/proj1.tfvars) to input all above defined variables.
    Remember to change image id from output of packer ![packer-template.png](./screenshot/packer-template.png) with your image id

## Implementing task `Deploying Your Infrastructure`
* Run cmd `ssh-keygen -t rsa -b 4096 -C "{{your-email-address}}"` to generate ssh key for linux machine
* Run cmd `terraform init` to download cloud provider azure resource manager
    Remember to go to terraform folder with cmd "cd terraform"
* Run cmd `terraform plan -out solution.plan -var-file proj1.tfvars` to save the ![plan](./screenshot/terraform-plan.png) which terraform will create all resources in the template with input variables
* Run cmd `terraform apply "solution.plan"` to start create ![resources](./screenshot/resources-apply.png) following solution.plan
* Run cmd `terraform destroy -var-file proj1.tfvars` to destroy all resources created above

### Structure
1. `packer` folder contains server template
2. `policy` folder contains policy definition template
3. `screenshots` folder contains all screenshots when run commands to create resources
4. `terraform` folder contains all infrastructure as code of project `Deploy a Web Server in Azure`