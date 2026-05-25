## AZ-700 Lab 1 - Recursos PowerShell ##
 
# Resource Group
New-AzResourceGroup `
  -Name $RG `
  -Location $LOCATION_EASTUS
 
Get-AzResourceGroup -Name $RG
 
 
# CoreServicesVnet - East US
$gw  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB4_NAME -AddressPrefix $VNET1_SUB4
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG `
  -Location $LOCATION_EASTUS `
  -Name $VNET1_NAME `
  -AddressPrefix $VNET1_PREFIX `
  -Subnet $gw, $db, $ss, $web
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME) | Select-Object Name, AddressPrefix
 
 
# ManufacturingVnet - West Europe
$mfg  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$sen1 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$sen2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$sen3 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG `
  -Location $LOCATION_WESTEU `
  -Name $VNET2_NAME `
  -AddressPrefix $VNET2_PREFIX `
  -Subnet $mfg, $sen1, $sen2, $sen3
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME) | Select-Object Name, AddressPrefix
 
 
# ResearchVnet - Southeast Asia
$res = New-AzVirtualNetworkSubnetConfig -Name $VNET3_SUB1_NAME -AddressPrefix $VNET3_SUB1
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG `
  -Location $LOCATION_SOUTHASIA `
  -Name $VNET3_NAME `
  -AddressPrefix $VNET3_PREFIX `
  -Subnet $res
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME) | Select-Object Name, AddressPrefix
 
 
# Validação final - todas as VNets do RG
Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location, AddressSpace