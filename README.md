# Infrastructure as Code example with Terraform setting up Azure resources
 Simple azure terraform example
 
**Step-by-step introduction here**
- https://philipnadm.github.io/iac-azure-terraform-example/
 
 # Quick guide:

## prerequisite
* Terraform:
  * https://www.terraform.io/downloads.html
  * you should be able to run `terraform -help`
* Azure CLI:
  * https://docs.microsoft.com/cli/azure
  * you should be able to run `az login`

## Nice to have
* Github client:
  * https://desktop.github.com
* A source-code editor (IDE)
  * https://code.visualstudio.com/


# USAGE

1. Fork and download
1. Create the file terraform.tfvars
    * set the variable app_name
    * `app_name = "<INSERT_HERE>"`
1. Initialize Terraform
    * `terraform init`
1. Terraform plan
    * `terraform plan`

If everything now works, it's time to create your resources in Azure.

1. Authenticate towards Azure (if you haven't already done this)
    * `az login`
1. Create all the resources
    * `terraform apply`

## Clean up

Remember to clean up and delete all the resources when the testing is done.

* `terraform destroy`

