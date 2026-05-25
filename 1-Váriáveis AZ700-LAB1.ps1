

## AZ-700 Lab 1 - Váriáveis ##

 
# General
$RG = "ContosoResourceGrouplod61979644"
$LOCATION_EASTUS    = "eastus"
$LOCATION_WESTEU    = "westeurope"
$LOCATION_SOUTHASIA = "southeastasia"
 
# CoreServicesVnet
$VNET1_NAME   = "CoreServicesVnet"
$VNET1_PREFIX = "10.20.0.0/16"
$VNET1_SUB1_NAME = "GatewaySubnet"
$VNET1_SUB1      = "10.20.0.0/27"
$VNET1_SUB2_NAME = "DatabaseSubnet"
$VNET1_SUB2      = "10.20.20.0/24"
$VNET1_SUB3_NAME = "SharedServicesSubnet"
$VNET1_SUB3      = "10.20.10.0/24"
$VNET1_SUB4_NAME = "PublicWebServiceSubnet"
$VNET1_SUB4      = "10.20.30.0/24"
 
# ManufacturingVnet
$VNET2_NAME   = "ManufacturingVnet"
$VNET2_PREFIX = "10.30.0.0/16"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"
$VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"
$VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"
$VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"
$VNET2_SUB4      = "10.30.22.0/24"
 
# ResearchVnet
$VNET3_NAME   = "ResearchVnet"
$VNET3_PREFIX = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet"
$VNET3_SUB1      = "10.40.0.0/24"