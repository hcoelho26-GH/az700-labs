terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_eastus
}

resource "azurerm_virtual_network" "core_services" {
  name                = var.vnet1_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet1_prefix]
}

resource "azurerm_subnet" "core_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes     = [var.vnet1_sub1]
}

resource "azurerm_subnet" "core_database" {
  name                 = var.vnet1_sub2_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes     = [var.vnet1_sub2]
}

resource "azurerm_subnet" "core_shared" {
  name                 = var.vnet1_sub3_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes     = [var.vnet1_sub3]
}

resource "azurerm_subnet" "core_web" {
  name                 = var.vnet1_sub4_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes     = [var.vnet1_sub4]
}

resource "azurerm_virtual_network" "manufacturing" {
  name                = var.vnet2_name
  location            = var.location_westeu
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet2_prefix]
}

resource "azurerm_subnet" "mfg_system" {
  name                 = var.vnet2_sub1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes     = [var.vnet2_sub1]
}

resource "azurerm_subnet" "mfg_sensor1" {
  name                 = var.vnet2_sub2_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes     = [var.vnet2_sub2]
}

resource "azurerm_subnet" "mfg_sensor2" {
  name                 = var.vnet2_sub3_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes     = [var.vnet2_sub3]
}

resource "azurerm_subnet" "mfg_sensor3" {
  name                 = var.vnet2_sub4_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes     = [var.vnet2_sub4]
}

resource "azurerm_virtual_network" "research" {
  name                = var.vnet3_name
  location            = var.location_southasia
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet3_prefix]
}

resource "azurerm_subnet" "research_system" {
  name                 = var.vnet3_sub1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.research.name
  address_prefixes     = [var.vnet3_sub1]
}
