resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

#Create a public IP for loadbalancer
resource "azurerm_public_ip" "azure-lbpip" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags = var.tags
}

resource "azurerm_lb" "azure-lb" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.azure-lbpip.id
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "lb-be" {
  resource_group_name = azurerm_resource_group.azure-rg.name
  loadbalancer_id     = azurerm_lb.azure-lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb-probe" {
  resource_group_name = azurerm_resource_group.azure-rg.name
  loadbalancer_id     = azurerm_lb.azure-lb.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = azurerm_resource_group.azure-rg.name
  loadbalancer_id                = azurerm_lb.azure-lb.id
  name                           = "http"
  protocol                       = "TCP"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb-be.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.lb-probe.id
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "vmscaleset"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = var.linux_admin_user
    admin_password       = var.linux_admin_password
    custom_data          = file("web.conf")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.azure-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb-be.id]
      primary                                = true
    }
  }

  tags = var.tags
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
  tags = var.tags
}

#Associate the Web NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "azure-web-nsg-association" {
  subnet_id                 = azurerm_subnet.azure-subnet.id
  network_security_group_id = azurerm_network_security_group.azure-web-nsg.id
}

#Output
output "external-ip-azure-web-server" {
  value = azurerm_public_ip.azure-lbpip.ip_address
}