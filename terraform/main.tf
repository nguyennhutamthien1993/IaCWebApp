provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.application}-${var.environment}-${var.location_abbreviation}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

resource "azurerm_subnet" "web_subnet" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "web-subnet-${var.application}-${var.environment}-${var.location_abbreviation}"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = var.resource_group_name
}

resource "azurerm_network_security_group" "web_subnet_nsg" {
  name                = "nsg-${var.application}-${var.environment}-${var.location_abbreviation}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "deny_inbound_internet" {
  name                        = "DenyInboundInternet"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

resource "azurerm_network_security_rule" "allow_inbound_vnet" {
  name                        = "AllowInboundVnet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_virtual_network.vnet.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

resource "azurerm_network_security_rule" "allow_http_lb" {
  depends_on = [ azurerm_public_ip.pip_lb ]
  name                        = "AllowInboundLoadBalancer"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = azurerm_public_ip.pip_lb.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

resource "azurerm_network_security_rule" "allow_outbound_vnet" {
  name                        = "AllowOutboundVnet"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_virtual_network.vnet.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  depends_on                = [azurerm_network_security_rule.deny_inbound_internet, azurerm_network_security_rule.allow_inbound_vnet, azurerm_network_security_rule.allow_http_lb, azurerm_network_security_rule.allow_outbound_vnet]
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.web_subnet_nsg.id
}

resource "azurerm_network_interface" "nic_vmss" {
  name                = "nic-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "web-vmss-${var.application}-${var.environment}-${var.location_abbreviation}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_DS1_v2"
  instances           = var.instance_count
  admin_username      = var.vm_root_username
  source_image_id     = var.image_linux
  tags                = var.common_tags

  admin_ssh_key {
    username   = var.vm_root_username
    public_key = file("${path.module}/ssh-keys/ssh-key.pub")
  }

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  upgrade_mode = "Automatic"

  network_interface {
    name    = "nic-web-vmss-${var.application}-${var.environment}-${var.location_abbreviation}"
    primary = true
    ip_configuration {
      name                                   = "pip-web-vmss"
      subnet_id                              = azurerm_subnet.web_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_address_pool_web_lb.id]
    }
  }
}

resource "azurerm_public_ip" "pip_lb" {
  name                = "pip-lb-${var.application}-${var.environment}-${var.location_abbreviation}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_lb" "web_lb" {
  name                = "lb-${var.application}-${var.environment}-${var.location_abbreviation}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "pip-lb-${var.application}-${var.environment}-${var.location_abbreviation}"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool_web_lb" {
  name            = "bep-lb-${var.application}-${var.environment}-${var.location_abbreviation}"
  loadbalancer_id = azurerm_lb.web_lb.id
}

resource "azurerm_lb_probe" "probe_web_lb" {
  name            = "probe-lb-${var.application}-${var.environment}-${var.location_abbreviation}"
  protocol        = "Tcp"
  port            = 8080
  loadbalancer_id = azurerm_lb.web_lb.id
}

resource "azurerm_lb_rule" "rule_web_lb" {
  name                           = "rule-lb-${var.application}-${var.environment}-${var.location_abbreviation}"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.web_lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.probe_web_lb.id
  loadbalancer_id                = azurerm_lb.web_lb.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_address_pool_web_lb.id]
}
