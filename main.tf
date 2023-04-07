terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "api-rg-pro"
  location = "West Europe"
}

resource "azurerm_public_ip" "loadip" {
  name                = "TestPublicIp1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_lb" "appload" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.loadip.id
  }
  depends_on = [
    azurerm_public_ip.loadip
  ]
}


resource "azurerm_lb_backend_address_pool" "backpool" {
  loadbalancer_id = azurerm_lb.appload.id
  name            = "BackEndAddressPool"

  depends_on = [
    azurerm_lb.appload
  ]
}

/*
resource "azurerm_lb_backend_address_pool_address" "appadress" {
  name                    = "example"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backpool.id
  virtual_network_id      = azurerm_virtual_network.example.id  # jo tum virtual machine k liye bnaounge wo
  ip_address              = azurerm_network_interface.appinterface.private_ip_address  # yaha network interface ka refernce dena h jo tum virtual machine k liye bana rahe ho

  depends_on = [
    azurerm_lb_backend_address_pool.backpool,
    azurerm_network_interface.appinterface
  ]
}

*/

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.appload.id
  name            = "probeA"
  port            = 80
  protocol = "Tcp"

  depends_on = [
    azurerm_lb.appload
  ]
}

resource "azurerm_lb_rule" "lbrule" {
  loadbalancer_id                = azurerm_lb.appload.id
  name                           = "LBRuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backpool.id]
  probe_id                       = azurerm_lb_probe.probe.id

  depends_on = [
    azurerm_lb.appload
  ]
}





vnet ke sath load balancer create k backend pool m interface id ko mention kr dena


