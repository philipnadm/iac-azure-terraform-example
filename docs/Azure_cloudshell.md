## For de av dere som ikke har en IDE, eller Terraform i path ;)
1. Logg inn på portal.azure.com
2. Velg Cloud shell øverst på skjermen til høyre - ser ut som powershell logo
3. Konfigurer shell - følg veiviser

## For å opprette filer:
I kommandovinduet skriver du "code filnavn" for hver fil du skal opprette - eks code main.tf

## main.tf
```
#Configure the state location
terraform {
  backend "azurerm" {
    resource_group_name   = "philip-tfstate"
    storage_account_name  = "philstfstate"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

#Configure the Azure Provider
provider "azurerm" {
  version = ">= 2.33"
  features {}
}

#Create Resource Group
resource "azurerm_resource_group" "azure-rg" {
  name     = "${var.app_name}-${var.app_environment}-rg"
  location = var.rg_location
}

#Create a virtual network
resource "azurerm_virtual_network" "azure-vnet" {
  name                = "${var.app_name}-${var.app_environment}-vnet"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = var.rg_location
  address_space       = [var.azure_vnet_cidr]
  tags = {
    environment = var.app_environment,
    responsible = var.department_id
  }
}

#Create a subnet
resource "azurerm_subnet" "azure-subnet" {
  name                 = "${var.app_name}-${var.app_environment}-subnet"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = azurerm_virtual_network.azure-vnet.name
  address_prefixes     = [var.azure_subnet_cidr]
}

#Create Security Group to access Web Server
resource "azurerm_network_security_group" "azure-web-nsg" {
  name                = "${var.app_name}-${var.app_environment}-web-nsg"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name

  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = {
    environment = var.app_environment,
    responsible = var.department_id
  }
}

#Associate the Web NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "azure-web-nsg-association" {
  subnet_id                 = azurerm_subnet.azure-subnet.id
  network_security_group_id = azurerm_network_security_group.azure-web-nsg.id
}

#Get a Static Public IP
resource "azurerm_public_ip" "azure-web-ip" {
  name                = "${var.app_name}-${var.app_environment}-web-ip"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name
  allocation_method   = "Static"

  tags = {
    environment = var.app_environment,
    responsible = var.department_id
  }
}

#Create Network Card for Web Server VM
resource "azurerm_network_interface" "azure-web-nic" {
  name                = "${var.app_name}-${var.app_environment}-web-nic"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azure-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure-web-ip.id
  }

  tags = {
    environment = var.app_environment,
    responsible = var.department_id
  }
}

# Create web server vm
resource "azurerm_linux_virtual_machine" "azure-web-vm" {
  name                             = "${var.app_name}-${var.app_environment}-web-vm"
  location                         = azurerm_resource_group.azure-rg.location
  resource_group_name              = azurerm_resource_group.azure-rg.name
  network_interface_ids            = [azurerm_network_interface.azure-web-nic.id]
  size                             = "Standard_B1s"

  computer_name  = var.linux_vm_hostname
  admin_username = var.linux_admin_user
  admin_password = var.linux_admin_password
  disable_password_authentication = false



  source_image_reference {
    publisher = var.ubuntu-linux-publisher
    offer     = var.ubuntu-linux-offer
    sku       = var.ubuntu-linux-18-sku
    version   = "latest"
  }

  os_disk {
    name              = "${var.app_name}-${var.app_environment}-web-vm-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # It's easy to transfer files or templates using Terraform.
  provisioner "file" {
    source      = "files/setup.sh"
    destination = "/home/${var.linux_admin_user}/setup.sh"

    connection {
      type     = "ssh"
      user     = var.linux_admin_user
      password = var.linux_admin_password
      host     = azurerm_public_ip.azure-web-ip.ip_address
    }
  }

  # This shell script starts our Apache server and prepares the demo environment.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.linux_admin_user}/setup.sh",
      "sudo /home/${var.linux_admin_user}/setup.sh",
    ]

    connection {
      type     = "ssh"
      user     = var.linux_admin_user
      password = var.linux_admin_password
      host     = azurerm_public_ip.azure-web-ip.ip_address
    }
  }

  tags = {
    environment = var.app_environment,
    responsible = var.department_id
  }
}


#Output
output "external-ip-azure-web-server" {
  value = azurerm_public_ip.azure-web-ip.ip_address
}
```
