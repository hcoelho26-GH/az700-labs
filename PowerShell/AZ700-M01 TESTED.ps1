## AZ-700 M01 - Variables ##

# General
$RG              = "ContosoResourceGrouplod61979644"
$LOCATION_EASTUS    = "eastus"
$LOCATION_WESTEU    = "westeurope"
$LOCATION_SOUTHASIA = "southeastasia"

# CoreServicesVnet
$VNET1_NAME      = "CoreServicesVnet"
$VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_SUB1_NAME = "GatewaySubnet"
$VNET1_SUB1      = "10.20.0.0/27"
$VNET1_SUB2_NAME = "DatabaseSubnet"
$VNET1_SUB2      = "10.20.20.0/24"
$VNET1_SUB3_NAME = "SharedServicesSubnet"
$VNET1_SUB3      = "10.20.10.0/24"
$VNET1_SUB4_NAME = "PublicWebServiceSubnet"
$VNET1_SUB4      = "10.20.30.0/24"

# ManufacturingVnet
$VNET2_NAME      = "ManufacturingVnet"
$VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"
$VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"
$VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"
$VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"
$VNET2_SUB4      = "10.30.22.0/24"

# ResearchVnet
$VNET3_NAME      = "ResearchVnet"
$VNET3_PREFIX    = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet"
$VNET3_SUB1      = "10.40.0.0/24"

# DNS (Unit 6)
$DNS_ZONE      = "Contoso.com"
$DNS_LINK_NAME = "CoreServicesVnetLink"

# VMs Unit 6
$VM1_NAME  = "testvm1"
$VM2_NAME  = "testvm2"
$NIC1_NAME = "testvm1-nic"
$NIC2_NAME = "testvm2-nic"
$NSG1_NAME = "testvm1-nsg"
$NSG2_NAME = "testvm2-nsg"
$PIP1_NAME = "testvm1-pip"
$PIP2_NAME = "testvm2-pip"

# VM Unit 8
$MFG_VM_NAME     = "ManufacturingVM"
$MFG_NIC_NAME    = "ManufacturingVM-nic"
$MFG_NSG_NAME    = "ManufacturingVM-nsg"
$MFG_PIP_NAME    = "ManufacturingVM-pip"
$MFG_SUBNET_NAME = "ManufacturingSystemSubnet"

# Peerings Unit 8
$PEERING1_NAME = "CoreServicesVnet-to-ManufacturingVnet"
$PEERING2_NAME = "ManufacturingVnet-to-CoreServicesVnet"

# Comum VMs
$VM_SIZE    = "Standard_D2s_v3"
$ADMIN_USER = "TestUser"


## AZ-700 M01 - Resources ##
 
 
# Unit 4 - Task 1 - Resource Group
 
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS
 
Get-AzResourceGroup -Name $RG
 
 
# Unit 4 - Task 2 - CoreServicesVnet - East US
 
$gw  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB4_NAME -AddressPrefix $VNET1_SUB4
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION_EASTUS `
  -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX `
  -Subnet $gw, $db, $ss, $web
 
 
# Unit 4 - Task 3 - ManufacturingVnet - West Europe
 
$mfg  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$sen1 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$sen2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$sen3 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION_WESTEU `
  -Name $VNET2_NAME -AddressPrefix $VNET2_PREFIX `
  -Subnet $mfg, $sen1, $sen2, $sen3
 
 
# Unit 4 - Task 4 - ResearchVnet - Southeast Asia
 
$res = New-AzVirtualNetworkSubnetConfig -Name $VNET3_SUB1_NAME -AddressPrefix $VNET3_SUB1
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION_SOUTHASIA `
  -Name $VNET3_NAME -AddressPrefix $VNET3_PREFIX `
  -Subnet $res
 
 
# Unit 4 - Task 5 - Check VNets e Subnets
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME) | Select-Object Name, AddressPrefix
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME) | Select-Object Name, AddressPrefix
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME) | Select-Object Name, AddressPrefix
 
Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location, AddressSpace
 
 
# Unit 6 - Task 1 - Create Private DNS Zone
 
New-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
 
Get-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
 
 
# Unit 6 - Task 2 - Link VNet to auto registration
 
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
 
New-AzPrivateDnsVirtualNetworkLink `
  -ResourceGroupName $RG -ZoneName $DNS_ZONE `
  -Name $DNS_LINK_NAME -VirtualNetworkId $vnet.Id `
  -EnableRegistration
 
Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG -ZoneName $DNS_ZONE -Name $DNS_LINK_NAME
 
 
# Unit 6 - Task 3 - Create testvm1 and testvm2
 
$adminPassword = Read-Host "Password for the VMs" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$subnetId      = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $VNET1_SUB2_NAME).Id
 
# testvm1
$pip1     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $PIP1_NAME -Sku Standard -AllocationMethod Static
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg1     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NSG1_NAME -SecurityRules $nsgRule1
$nic1     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NIC1_NAME -SubnetId $subnetId -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
 
$vm1Config = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic1.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm1Config
 
# testvm2
$pip2     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $PIP2_NAME -Sku Standard -AllocationMethod Static
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg2     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NSG2_NAME -SecurityRules $nsgRule2
$nic2     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NIC2_NAME -SubnetId $subnetId -PublicIpAddressId $pip2.Id -NetworkSecurityGroupId $nsg2.Id
 
$vm2Config = New-AzVMConfig -VMName $VM2_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM2_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic2.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm2Config
 
Get-AzVM -ResourceGroupName $RG | Select-Object Name, Location
 
 
# Unit 6 - Task 4 - Check DNS records
 
Get-AzPrivateDnsRecordSet -ResourceGroupName $RG -ZoneName $DNS_ZONE -RecordType A
 
 
# Unit 8 - Task 1 - Create ManufacturingVM
 
$vnet2    = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$subnetId2 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet2 -Name $MFG_SUBNET_NAME).Id
 
$pip      = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_PIP_NAME -Sku Standard -AllocationMethod Static
$nsgRule  = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg      = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_NSG_NAME -SecurityRules $nsgRule
$nic      = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_NIC_NAME -SubnetId $subnetId2 -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id
 
$vmConfig = New-AzVMConfig -VMName $MFG_VM_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $MFG_VM_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION_WESTEU -VM $vmConfig
 
Get-AzVM -ResourceGroupName $RG -Name $MFG_VM_NAME | Select-Object Name, Location
 
 
# Unit 8 - Tasks 2 and 3 - Manual (RDP)
# Enable RDP on ManufacturingVM and testvm1
# Run on ManufacturingVM: Test-NetConnection 10.20.20.4 -port 3389
# Expected result: fail (no peering configured yet)
 
 
# Unit 8 - Task 4 - Create VNet Peerings
 
$vnet1 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
 
Add-AzVirtualNetworkPeering `
  -Name $PEERING1_NAME -VirtualNetwork $vnet1 `
  -RemoteVirtualNetworkId $vnet2.Id -AllowForwardedTraffic
 
Add-AzVirtualNetworkPeering `
  -Name $PEERING2_NAME -VirtualNetwork $vnet2 `
  -RemoteVirtualNetworkId $vnet1.Id -AllowForwardedTraffic
 
Get-AzVirtualNetworkPeering -ResourceGroupName $RG -VirtualNetworkName $VNET1_NAME | Select-Object Name, PeeringState
Get-AzVirtualNetworkPeering -ResourceGroupName $RG -VirtualNetworkName $VNET2_NAME | Select-Object Name, PeeringState
 
 
# Unit 8 - Task 5 - Manual (RDP)
# Run on ManufacturingVM: Test-NetConnection 10.20.20.4 -port 3389
# Expected result: TcpTestSucceeded: True
 