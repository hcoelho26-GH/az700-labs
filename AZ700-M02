## AZ-700 M02 - Variáveis ##
 
# Geral
$RG              = "ContosoResourceGroup"
$LOCATION_EASTUS = "eastus"
$LOCATION_WESTEU = "westeurope"
 
# CoreServicesVnet
$VNET1_NAME      = "CoreServicesVnet"
$VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_GW_NAME   = "GatewaySubnet"
$VNET1_GW        = "10.20.0.0/27"
$VNET1_SUB1_NAME = "DatabaseSubnet"
$VNET1_SUB1      = "10.20.20.0/24"
$VNET1_SUB2_NAME = "SharedServicesSubnet"
$VNET1_SUB2      = "10.20.10.0/24"
$VNET1_SUB3_NAME = "PublicWebServiceSubnet"
$VNET1_SUB3      = "10.20.30.0/24"
 
# ManufacturingVnet
$VNET2_NAME      = "ManufacturingVnet"
$VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_GW_NAME   = "GatewaySubnet"
$VNET2_GW        = "10.30.0.0/27"
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
 
# VPN Gateways 
$GW1_NAME   = "CoreServicesVnetGateway"
$GW1_PIP    = "CoreServicesVnetGateway-ip"
$GW2_NAME   = "ManufacturingVnetGateway"
$GW2_PIP    = "ManufacturingVnetGateway-ip"
$GW_SKU     = "VpnGw1AZ"
$GW_GEN     = "Generation1"
 
# Conexões VPN 
$CONN1_NAME = "CoreServicesGW-to-ManufacturingGW"
$CONN2_NAME = "ManufacturingGW-to-CoreServicesGW"
$SHARED_KEY = "abc123"
 
# CoreServicesVM 
$VM1_NAME   = "CoreServicesVM"
$VM1_NIC    = "CoreServicesVM-nic"
$VM1_NSG    = "CoreServicesVM-nsg"
$VM1_PIP    = "CoreServicesVM-pip"
 
# ManufacturingVM
$VM2_NAME   = "ManufacturingVM"
$VM2_NIC    = "ManufacturingVM-nic"
$VM2_NSG    = "ManufacturingVM-nsg"
$VM2_PIP    = "ManufacturingVM-pip"
 
# Comum VMs
$VM_SIZE    = "Standard_D2s_v3"
$ADMIN_USER = "TestUser"
 
# Virtual WAN 
$VWAN_NAME  = "ContosoVirtualWAN"
$VWAN_RG    = "ContosoResourceGroup"
$HUB_NAME   = "ContosoHub"
$HUB_PREFIX = "10.60.0.0/24"
$VWAN_CONN  = "ContosoVirtualWAN-to-ResearchVNet"

## AZ-700 M02 - Recursos ##
 
 
# Unit 3 - Task 1 - Criar VNets e Resource Group
 
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS
 
# CoreServicesVnet - East US
$gw1 = New-AzVirtualNetworkSubnetConfig -Name $VNET1_GW_NAME   -AddressPrefix $VNET1_GW
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION_EASTUS `
  -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX `
  -Subnet $gw1, $db, $ss, $web
 
# ManufacturingVnet - West Europe
$gw2  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_GW_NAME   -AddressPrefix $VNET2_GW
$mfg  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$sen1 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$sen2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$sen3 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
 
New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION_WESTEU `
  -Name $VNET2_NAME -AddressPrefix $VNET2_PREFIX `
  -Subnet $gw2, $mfg, $sen1, $sen2, $sen3
 
Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location
 
 
# Unit 3 - Task 2 - CoreServicesVM
$adminPassword = Read-Host "Password para as VMs" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
 
$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$subnetId1 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet1 -Name $VNET1_SUB1_NAME).Id
 
$pip1     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_PIP -Sku Standard -AllocationMethod Static
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg1     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NSG -SecurityRules $nsgRule1
$nic1     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NIC -SubnetId $subnetId1 -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
 
$vm1Config = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic1.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm1Config
 
 
# Unit 3 - Task 3 - ManufacturingVM
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$subnetId2 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet2 -Name $VNET2_SUB1_NAME).Id
 
$pip2     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_PIP -Sku Standard -AllocationMethod Static
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg2     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_NSG -SecurityRules $nsgRule2
$nic2     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_NIC -SubnetId $subnetId2 -PublicIpAddressId $pip2.Id -NetworkSecurityGroupId $nsg2.Id
 
$vm2Config = New-AzVMConfig -VMName $VM2_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM2_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic2.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION_WESTEU -VM $vm2Config
 
Get-AzVM -ResourceGroupName $RG | Select-Object Name, Location
 
 
# Unit 3 - Tasks 4 e 5 - Manuais (RDP)
# Ligar via RDP ao CoreServicesVM e ManufacturingVM
# Correr no CoreServicesVM: ipconfig  → anotar IPv4
# Correr no ManufacturingVM: Test-NetConnection <IP_CoreServicesVM> -port 3389
# Esperado: falhar (ainda sem gateway)
 
 
# Unit 3 - Task 6 - CoreServicesVnet Gateway
# ATENÇÃO: demora até 45 minutos — avança para Task 7 enquanto espera
 
$pipGw1    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$gwSubnet1 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
 
$gwIpConfig1 = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig1" -SubnetId $gwSubnet1.Id -PublicIpAddressId $pipGw1.Id
 
New-AzVirtualNetworkGateway `
  -ResourceGroupName $RG -Location $LOCATION_EASTUS `
  -Name $GW1_NAME -IpConfigurations $gwIpConfig1 `
  -GatewayType VPN -VpnType RouteBased `
  -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN
 
 
# Unit 3 - Task 7 - ManufacturingVnet Gateway
# ATENÇÃO: demora até 45 minutos — avança enquanto espera
 
$pipGw2    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$gwSubnet2 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2
 
$gwIpConfig2 = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig2" -SubnetId $gwSubnet2.Id -PublicIpAddressId $pipGw2.Id
 
New-AzVirtualNetworkGateway `
  -ResourceGroupName $RG -Location $LOCATION_WESTEU `
  -Name $GW2_NAME -IpConfigurations $gwIpConfig2 `
  -GatewayType VPN -VpnType RouteBased `
  -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN
 
 
# Unit 3 - Task 8 - Ligar os dois Gateways
# Só correr depois de ambos os gateways terem ProvisioningState = Succeeded
 
$gw1Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME
$gw2Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME
 
New-AzVirtualNetworkGatewayConnection `
  -ResourceGroupName $RG -Location $LOCATION_EASTUS `
  -Name $CONN1_NAME -ConnectionType Vnet2Vnet `
  -VirtualNetworkGateway1 $gw1Obj -VirtualNetworkGateway2 $gw2Obj `
  -SharedKey $SHARED_KEY -EnableBgp $false
 
New-AzVirtualNetworkGatewayConnection `
  -ResourceGroupName $RG -Location $LOCATION_WESTEU `
  -Name $CONN2_NAME -ConnectionType Vnet2Vnet `
  -VirtualNetworkGateway1 $gw2Obj -VirtualNetworkGateway2 $gw1Obj `
  -SharedKey $SHARED_KEY -EnableBgp $false
 
 
# Unit 3 - Task 9 - Verificar conexões
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN1_NAME | Select-Object Name, ConnectionStatus
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN2_NAME | Select-Object Name, ConnectionStatus
 
 
# Unit 3 - Tasks 10 e 11 - Manuais (RDP)
# Correr no ManufacturingVM: Test-NetConnection <IP_CoreServicesVM> -port 3389
# Esperado: TcpTestSucceeded: True
 
 
# Unit 7 - Task 1 - Criar Virtual WAN
 
New-AzVirtualWan `
  -ResourceGroupName $VWAN_RG `
  -Name $VWAN_NAME `
  -Location $LOCATION_EASTUS `
  -VirtualWANType Standard
 
Get-AzVirtualWan -ResourceGroupName $VWAN_RG -Name $VWAN_NAME | Select-Object Name, Location, ProvisioningState
 
 
# Unit 7 - Task 2 - Criar Hub
# ATENÇÃO: demora até 30 minutos
 
New-AzVirtualHub `
  -ResourceGroupName $VWAN_RG `
  -Name $HUB_NAME `
  -Location $LOCATION_EASTUS `
  -VirtualWan (Get-AzVirtualWan -ResourceGroupName $VWAN_RG -Name $VWAN_NAME) `
  -AddressPrefix $HUB_PREFIX
 
Get-AzVirtualHub -ResourceGroupName $VWAN_RG -Name $HUB_NAME | Select-Object Name, Location, ProvisioningState
 
 
# Unit 7 - Task 3 - Ligar ResearchVnet ao Hub
 
# Criar ResearchVnet se ainda não existir
$res = New-AzVirtualNetworkSubnetConfig -Name $VNET3_SUB1_NAME -AddressPrefix $VNET3_SUB1
New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION_EASTUS `
  -Name $VNET3_NAME -AddressPrefix $VNET3_PREFIX `
  -Subnet $res
 
$hub   = Get-AzVirtualHub -ResourceGroupName $VWAN_RG -Name $HUB_NAME
$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME
 
New-AzVirtualHubVnetConnection `
  -ResourceGroupName $VWAN_RG `
  -VirtualHubName $HUB_NAME `
  -Name $VWAN_CONN `
  -RemoteVirtualNetwork $vnet3
 
Get-AzVirtualHubVnetConnection -ResourceGroupName $VWAN_RG -VirtualHubName $HUB_NAME -Name $VWAN_CONN | Select-Object Name, ProvisioningState