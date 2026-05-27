## AZ-700 Lab 1 - Váriáveis ##
# General
$RG = "ContosoResourceGrouplod61979644"
$LOCATION_EASTUS    = "eastus"
$LOCATION_WESTEU    = "westeurope"
$LOCATION_SOUTHASIA = "southeastasia"

# DNS Zone
$DNS_ZONE = "Contoso.com"
$DNS_LINK_NAME = "CoreServicesVnetLink"

## VNet para link
$VNET_NAME = "CoreServicesVnet"
$SUBNET_NAME = "DatabaseSubnet"

# VMs
$VM1_NAME = "testvm1"
$VM2_NAME = "testvm2"
$NIC1_NAME = "testvm1-nic"
$NIC2_NAME = "testvm2-nic"
$NSG1_NAME = "testvm1-nsg"
$NSG2_NAME = "testvm2-nsg"
$PIP1_NAME = "testvm1-pip"
$PIP2_NAME = "testvm2-pip"
$VM_SIZE = "Standard_D2s_v3"
$VM_IMAGE = "Win2019Datacenter"
$ADMIN_USER = "TestUser"
 
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

# Criar Private DNS Zone
New-AzPrivateDnsZone `
  -ResourceGroupName $RG `
  -Name $DNS_ZONE
 
Get-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
 
 
# Link da VNet para auto registration
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
 
New-AzPrivateDnsVirtualNetworkLink `
  -ResourceGroupName $RG `
  -ZoneName $DNS_ZONE `
  -Name $DNS_LINK_NAME `
  -VirtualNetworkId $vnet.Id `
  -EnableRegistration
 
Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG -ZoneName $DNS_ZONE -Name $DNS_LINK_NAME
 
 
# Criar VMs
$adminPassword = Read-Host "Password para as VMs" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_NAME).Id
 
# testvm1
$pip1 = New-AzPublicIpAddress `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $PIP1_NAME `
  -Sku Standard `
  -AllocationMethod Static
 
$nsgRule1 = New-AzNetworkSecurityRuleConfig `
  -Name "default-allow-rdp" `
  -Priority 1000 `
  -Protocol Tcp `
  -Access Allow `
  -Direction Inbound `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389
 
$nsg1 = New-AzNetworkSecurityGroup `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $NSG1_NAME `
  -SecurityRules $nsgRule1
 
$nic1 = New-AzNetworkInterface `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $NIC1_NAME `
  -SubnetId $subnetId `
  -PublicIpAddressId $pip1.Id `
  -NetworkSecurityGroupId $nsg1.Id
 
$vm1Config = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic1.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vm1Config
 
# testvm2
$pip2 = New-AzPublicIpAddress `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $PIP2_NAME `
  -Sku Standard `
  -AllocationMethod Static
 
$nsgRule2 = New-AzNetworkSecurityRuleConfig `
  -Name "default-allow-rdp" `
  -Priority 1000 `
  -Protocol Tcp `
  -Access Allow `
  -Direction Inbound `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389
 
$nsg2 = New-AzNetworkSecurityGroup `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $NSG2_NAME `
  -SecurityRules $nsgRule2
 
$nic2 = New-AzNetworkInterface `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $NIC2_NAME `
  -SubnetId $subnetId `
  -PublicIpAddressId $pip2.Id `
  -NetworkSecurityGroupId $nsg2.Id
 
$vm2Config = New-AzVMConfig -VMName $VM2_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM2_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic2.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vm2Config
 
Get-AzVM -ResourceGroupName $RG | Select-Object Name, Location
 
# Verificar registos DNS
Get-AzPrivateDnsRecordSet -ResourceGroupName $RG -ZoneName $DNS_ZONE -RecordType A