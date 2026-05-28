variable "resource_group_name" {
  type    = string
}

variable "location_eastus" {
  type    = string
  default = "eastus"
}

variable "location_westeu" {
  type    = string
  default = "westeurope"
}

variable "location_southasia" {
  type    = string
  default = "southeastasia"
}

variable "vnet1_name" {
  type    = string
  default = "CoreServicesVnet"
}

variable "vnet1_prefix" {
  type    = string
  default = "10.20.0.0/16"
}

variable "vnet1_sub1" {
  type    = string
  default = "10.20.0.0/27"
}

variable "vnet1_sub2_name" {
  type    = string
  default = "DatabaseSubnet"
}

variable "vnet1_sub2" {
  type    = string
  default = "10.20.20.0/24"
}

variable "vnet1_sub3_name" {
  type    = string
  default = "SharedServicesSubnet"
}

variable "vnet1_sub3" {
  type    = string
  default = "10.20.10.0/24"
}

variable "vnet1_sub4_name" {
  type    = string
  default = "PublicWebServiceSubnet"
}

variable "vnet1_sub4" {
  type    = string
  default = "10.20.30.0/24"
}

variable "vnet2_name" {
  type    = string
  default = "ManufacturingVnet"
}

variable "vnet2_prefix" {
  type    = string
  default = "10.30.0.0/16"
}

variable "vnet2_sub1_name" {
  type    = string
  default = "ManufacturingSystemSubnet"
}

variable "vnet2_sub1" {
  type    = string
  default = "10.30.10.0/24"
}

variable "vnet2_sub2_name" {
  type    = string
  default = "SensorSubnet1"
}

variable "vnet2_sub2" {
  type    = string
  default = "10.30.20.0/24"
}

variable "vnet2_sub3_name" {
  type    = string
  default = "SensorSubnet2"
}

variable "vnet2_sub3" {
  type    = string
  default = "10.30.21.0/24"
}

variable "vnet2_sub4_name" {
  type    = string
  default = "SensorSubnet3"
}

variable "vnet2_sub4" {
  type    = string
  default = "10.30.22.0/24"
}

variable "vnet3_name" {
  type    = string
  default = "ResearchVnet"
}

variable "vnet3_prefix" {
  type    = string
  default = "10.40.0.0/16"
}

variable "vnet3_sub1_name" {
  type    = string
  default = "ResearchSystemSubnet"
}

variable "vnet3_sub1" {
  type    = string
  default = "10.40.0.0/24"
}
