## AZ-700 M03 - Variables ##

# General
$RG_CORE   = "ContosoResourceGroup"
$RG_ER     = "ExpressRouteResourceGroup"
$LOCATION  = "eastus"
$LOCATION2 = "eastus2"

# Part 4 - ExpressRoute Gateway
$VNET_NAME   = "CoreServicesVNet"           ; $VNET_PREFIX = "10.20.0.0/16"
$GW_SUB_NAME = "GatewaySubnet"              ; $GW_SUB      = "10.20.0.0/27"
$GW_NAME     = "CoreServicesVnetGateway"
$GW_PIP      = "CoreServicesVnetGateway-ip"
$GW_SKU      = "Standard"

# Part 5 - ExpressRoute Circuit
$ER_NAME     = "TestERCircuit"
$ER_LOCATION = "eastus2"
$ER_PEERING  = "Seattle"
$ER_PROVIDER = "Equinix"
$ER_BW       = 50
$ER_SKU      = "Standard"
$ER_BILLING  = "MeteredData"


## AZ-700 M03 - Resources ##


# Part 4 - Task 1 - VNet + GatewaySubnet

New-AzResourceGroup -Name $RG_CORE -Location $LOCATION

$gwSub = New-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -AddressPrefix $GW_SUB

New-AzVirtualNetwork `
  -ResourceGroupName $RG_CORE `
  -Location $LOCATION `
  -Name $VNET_NAME `
  -AddressPrefix $VNET_PREFIX `
  -Subnet $gwSub

Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME) | Select-Object Name, AddressPrefix


# Part 4 - Task 2 - ExpressRoute Gateway
# NOTE: takes up to 45 minutes

$pipGw = New-AzPublicIpAddress `
  -ResourceGroupName $RG_CORE `
  -Location $LOCATION `
  -Name $GW_PIP `
  -Sku Standard `
  -AllocationMethod Static

$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME
$gwSub = Get-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -VirtualNetwork $vnet
$gwIp  = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig" -SubnetId $gwSub.Id -PublicIpAddressId $pipGw.Id

New-AzVirtualNetworkGateway `
  -ResourceGroupName $RG_CORE `
  -Location $LOCATION `
  -Name $GW_NAME `
  -IpConfigurations $gwIp `
  -GatewayType ExpressRoute `
  -GatewaySku $GW_SKU

Get-AzVirtualNetworkGateway -ResourceGroupName $RG_CORE -Name $GW_NAME | Select-Object Name, GatewayType, ProvisioningState


# Part 5 - Task 1 - Create ExpressRoute Circuit

New-AzResourceGroup -Name $RG_ER -Location $LOCATION2

New-AzExpressRouteCircuit `
  -ResourceGroupName $RG_ER `
  -Location $ER_LOCATION `
  -Name $ER_NAME `
  -SkuFamily $ER_BILLING `
  -SkuTier $ER_SKU `
  -ServiceProviderName $ER_PROVIDER `
  -PeeringLocation $ER_PEERING `
  -BandwidthInMbps $ER_BW


# Part 5 - Task 2 - Get Service Key

$circuit = Get-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME
Write-Host "Service Key: $($circuit.ServiceKey)"
Write-Host "Provider Status: $($circuit.ServiceProviderProvisioningState)"
Write-Host "Circuit Status: $($circuit.CircuitProvisioningState)"


# Part 5 - Task 3 - Deprovision and delete circuit
# Only run after provider shows ProviderStatus = NotProvisioned

Remove-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME -Force


# Cleanup
Remove-AzResourceGroup -Name $RG_CORE -Force -AsJob
Remove-AzResourceGroup -Name $RG_ER   -Force -AsJob
