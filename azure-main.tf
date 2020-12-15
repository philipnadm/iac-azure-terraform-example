#Configure the state location
terraform {
  backend "azurerm" {
    resource_group_name  = "philip-tfstate"
    storage_account_name = "philstfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

#Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.sub_id
  version         = ">= 2.33"
  features {}
}

#Create Resource Group
resource "azurerm_resource_group" "azure-rg" {
  name     = "${var.app_name}-${var.app_environment}-rg"
  location = var.rg_location
  tags = var.tags
}

#Create a virtual network
resource "azurerm_virtual_network" "azure-vnet" {
  name                = "${var.app_name}-${var.app_environment}-vnet"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = var.rg_location
  address_space       = [var.azure_vnet_cidr]
  tags = var.tags
  }

#Create a subnet
resource "azurerm_subnet" "azure-subnet" {
  name                 = "${var.app_name}-${var.app_environment}-subnet"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = azurerm_virtual_network.azure-vnet.name
  address_prefixes     = [var.azure_subnet_cidr]
}