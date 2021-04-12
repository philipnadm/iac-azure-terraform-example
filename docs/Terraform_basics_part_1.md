## Part one: Azure & Terraform basics

Every resource we deploy to our environment, will be stored in a state. The state determines what resources are deployed, and what dependencies they have. 

When working with a team, it is crucial to have the state in an accessible location for all members.

For the purpose of this workshop, we'll be looking at two approaches to create a save location for our state. 

---

### Step one - Creating a resource group, storage account and container

### Example one - Azure portal
Follow the instructor on Teams.

Note that you would normally use a private container with an access key, but for this example we're leaving everything default.

---

### Example two - Azure CLI (for the experienced)
Create a resource group in Norway East, with a container and access key.

Depending on the shell you're using, you might need to edit the variables. (E.g. in Powershell: $RESOURCE_GROUP_NAME)
```
#!/bin/bash

RESOURCE_GROUP_NAME=tstate$RANDOM
STORAGE_ACCOUNT_NAME=tstate$RANDOM
CONTAINER_NAME=tstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location norwayeast

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "resource_group_name: $RESOURCE_GROUP_NAME"
echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
```

---


### Step two - Adding our state configuration to Terraform
In the azure-main.tf file, add the following section, and add your own values:
```
#Configure the state location
terraform {
  backend "azurerm" {
    resource_group_name   = ""
    storage_account_name  = ""
    container_name        = ""
    key                   = "terraform.tfstate"
  }
}
```

---


### Step three - Authenticate to Azure

```
### Sign in to Azure using CLI
az login

### Check the default subscription
az account show

### Check the available subscriptions
az account list

### Select default subscription
az account set --subscription "Cloud 1 Philip Nerem"
```

---

### Talking points:
**Resource Groups**

**Tagging**

---

### Step four - Deploying our infrastructure
Now that we know we're targeting the correct Azure subscription, we're ready to deploy our infrastructure.

Make sure you are in your working directory
- C:\..\iac-azure-terraform-example>

Terraform has three main commands:

**Terraform init**

**Terraform plan**

**Terraform apply**

### Step 4a - init

- Run ```terraform init```

**Result:**
```
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching ">= 2.33.*"...
- Installing hashicorp/azurerm v2.36.0...
- Installed hashicorp/azurerm v2.36.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Step 4b - plan

- Run ```terraform plan``` 
#### Note that you can use the -out parameter, e.g. terraform plan -out myplan


### Step 4c - apply
- Run ```terraform apply```
#### If you used the out parameter in the last step, make sure to use terraform apply "myplan"

Take a note of the IP you got after the process finished.


---


### Step 5 - Verify

Now we can open our portal again, locate our resources and confirm that we've created all the resources we wanted to.

Open a new tab in your browser, enter the IP for the webserver you just created. Is something missing?

---


## Terraform apply/destroy -target=""

Terraform can be used to target single resources if you're required to change certain aspects of the infrastructure

Example to destroy our web server:

```
terraform destroy -target="azurerm_linux_virtual_machine.azure-web-vm"
```

---


## Cleanup -  DO NOT DO THIS YET!

- Run ```terraform destroy```
