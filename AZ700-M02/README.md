# M02 — VPN Gateway & Virtual WAN

## Variables

<details>
<summary>Show variables</summary>

```powershell
$RG              = "ContosoResourceGroup"
$LOCATION_EASTUS = "eastus"
$LOCATION_WESTEU = "westeurope"

$VNET1_NAME      = "CoreServicesVnet"       ; $VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_GW_NAME   = "GatewaySubnet"          ; $VNET1_GW        = "10.20.0.0/27"
$VNET1_SUB1_NAME = "DatabaseSubnet"         ; $VNET1_SUB1      = "10.20.20.0/24"
$VNET1_SUB2_NAME = "SharedServicesSubnet"   ; $VNET1_SUB2      = "10.20.10.0/24"
$VNET1_SUB3_NAME = "PublicWebServiceSubnet" ; $VNET1_SUB3      = "10.20.30.0/24"

$VNET2_NAME      = "ManufacturingVnet"          ; $VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_GW_NAME   = "GatewaySubnet"              ; $VNET2_GW        = "10.30.0.0/27"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"  ; $VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"              ; $VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"              ; $VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"              ; $VNET2_SUB4      = "10.30.22.0/24"

$VNET3_NAME      = "ResearchVnet"         ; $VNET3_PREFIX    = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet" ; $VNET3_SUB1      = "10.40.0.0/24"

$GW1_NAME = "CoreServicesVnetGateway"  ; $GW1_PIP = "CoreServicesVnetGateway-ip"
$GW2_NAME = "ManufacturingVnetGateway" ; $GW2_PIP = "ManufacturingVnetGateway-ip"
$GW_SKU   = "VpnGw1AZ"                 ; $GW_GEN  = "Generation1"

$CONN1_NAME = "CoreServicesGW-to-ManufacturingGW"
$CONN2_NAME = "ManufacturingGW-to-CoreServicesGW"
$SHARED_KEY = "abc123"

$VM1_NAME = "CoreServicesVM"  ; $VM1_NIC = "CoreServicesVM-nic"  ; $VM1_NSG = "CoreServicesVM-nsg"  ; $VM1_PIP = "CoreServicesVM-pip"
$VM2_NAME = "ManufacturingVM" ; $VM2_NIC = "ManufacturingVM-nic" ; $VM2_NSG = "ManufacturingVM-nsg" ; $VM2_PIP = "ManufacturingVM-pip"
$VM_SIZE    = "Standard_D2s_v3"
$ADMIN_USER = "TestUser"

$VWAN_NAME  = "ContosoVirtualWAN" ; $HUB_NAME  = "ContosoHub"
$HUB_PREFIX = "10.60.0.0/24"      ; $VWAN_CONN = "ContosoVirtualWAN-to-ResearchVNet"
```

</details>

---

## Part 3 — VPN Gateway

### Task 1 — Create VNets

> ⚠️ **LearnOnDemand**: use the ARM template below. PowerShell works in unrestricted environments.

<details>
<summary>ARM Template — LearnOnDemand (recommended)</summary>

Upload `azuredeploy.json` and `azuredeploy.parameters.json` to Cloud Shell, then run:

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS

New-AzResourceGroupDeployment `
  -ResourceGroupName $RG `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json
```

> Note: The ARM template does not create GatewaySubnet on ManufacturingVnet. Add it manually after deployment:

```powershell
$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
Add-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2 -AddressPrefix $VNET2_GW | Set-AzVirtualNetwork
```

</details>

<details>
<summary>PowerShell — unrestricted environments</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS

$gw1 = New-AzVirtualNetworkSubnetConfig -Name $VNET1_GW_NAME   -AddressPrefix $VNET1_GW
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX -Subnet $gw1,$db,$ss,$web

$gw2  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_GW_NAME   -AddressPrefix $VNET2_GW
$mfg  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$sen1 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$sen2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$sen3 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VNET2_NAME -AddressPrefix $VNET2_PREFIX -Subnet $gw2,$mfg,$sen1,$sen2,$sen3
Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location
```

</details>

---

### Tasks 2-3 — CoreServicesVM + ManufacturingVM

> ⚠️ **LearnOnDemand**: use the ARM templates below. PowerShell is blocked for VM creation in restricted subscriptions.

<details>
<summary>ARM Template — CoreServicesVM (LearnOnDemand)</summary>

Upload `CoreServicesVMazuredeploy.json` and `CoreServicesVMazuredeploy.parameters.json` to Cloud Shell, then run:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG `
  -Name "deploy-coreservicesvm" `
  -TemplateFile CoreServicesVMazuredeploy.json `
  -TemplateParameterFile CoreServicesVMazuredeploy.parameters.json `
  -adminPassword (Read-Host "CoreServicesVM Password" -AsSecureString) `
  -AsJob
```

</details>

<details>
<summary>ARM Template — ManufacturingVM (LearnOnDemand)</summary>

Upload `ManufacturingVMazuredeploy.json` and `ManufacturingVMazuredeploy.parameters.json` to Cloud Shell, then run:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG `
  -Name "deploy-manufacturingvm" `
  -TemplateFile ManufacturingVMazuredeploy.json `
  -TemplateParameterFile ManufacturingVMazuredeploy.parameters.json `
  -adminPassword (Read-Host "ManufacturingVM Password" -AsSecureString) `
  -AsJob
```

</details>

<details>
<summary>Check deployment status</summary>

```powershell
# Check background jobs
Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check deployment status in Azure
Get-AzResourceGroupDeployment -ResourceGroupName $RG | Select-Object DeploymentName, ProvisioningState
```

</details>

<details>
<summary>PowerShell — unrestricted environments</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$subnetId1 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet1 -Name $VNET1_SUB1_NAME).Id
$pip1     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_PIP -Sku Standard -AllocationMethod Static
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg1     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NSG -SecurityRules $nsgRule1
$nic1     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NIC -SubnetId $subnetId1 -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
$vm1Config = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic1.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm1Config

$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$subnetId2 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet2 -Name $VNET2_SUB1_NAME).Id
$pip2     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_PIP -Sku Standard -AllocationMethod Static
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg2     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_NSG -SecurityRules $nsgRule2
$nic2     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_NIC -SubnetId $subnetId2 -PublicIpAddressId $pip2.Id -NetworkSecurityGroupId $nsg2.Id
$vm2Config = New-AzVMConfig -VMName $VM2_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM2_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic2.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_WESTEU -VM $vm2Config
Get-AzVM -ResourceGroupName $RG | Select-Object Name, Location
```

</details>

**Tasks 4-5 — Manual**: RDP to CoreServicesVM → `ipconfig` → note IPv4. RDP to ManufacturingVM → `Test-NetConnection <IP> -port 3389` → expected: `False`

---

### Tasks 6-7 — VPN Gateways ⏱️ 45 min each

<details>
<summary>Show code</summary>

```powershell
# CoreServicesVnetGateway — East US
$pipGw1    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$gwSubnet1 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
$gwIp1     = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig1" -SubnetId $gwSubnet1.Id -PublicIpAddressId $pipGw1.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_NAME -IpConfigurations $gwIp1 -GatewayType VPN -VpnType RouteBased -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN -AsJob

# ManufacturingVnetGateway — West Europe (run immediately, do not wait)
$pipGw2    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$gwSubnet2 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2
$gwIp2     = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig2" -SubnetId $gwSubnet2.Id -PublicIpAddressId $pipGw2.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_NAME -IpConfigurations $gwIp2 -GatewayType VPN -VpnType RouteBased -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN -AsJob

# Check job status
Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check gateway status — run periodically until both show Succeeded
Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME | Select-Object Name, ProvisioningState
Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME | Select-Object Name, ProvisioningState
```

</details>

---

### Tasks 8-9 — VPN Connections ⛔ only after both gateways show Succeeded

<details>
<summary>Show code</summary>

```powershell
$gw1Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME
$gw2Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME
New-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $CONN1_NAME -ConnectionType Vnet2Vnet -VirtualNetworkGateway1 $gw1Obj -VirtualNetworkGateway2 $gw2Obj -SharedKey $SHARED_KEY -EnableBgp $false
New-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $CONN2_NAME -ConnectionType Vnet2Vnet -VirtualNetworkGateway1 $gw2Obj -VirtualNetworkGateway2 $gw1Obj -SharedKey $SHARED_KEY -EnableBgp $false
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN1_NAME | Select-Object Name, ConnectionStatus
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN2_NAME | Select-Object Name, ConnectionStatus
```

</details>

> After creating the connections, status starts as `Unknown` — this is normal. Wait 3-5 minutes and check again. Expected progression: `Unknown → Connecting → Connected`

```powershell
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN1_NAME | Select-Object Name, ConnectionStatus
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN2_NAME | Select-Object Name, ConnectionStatus
```

**Tasks 10-11 — Manual**: RDP to ManufacturingVM → `Test-NetConnection <IP_CoreServicesVM> -port 3389` → expected: `True`

---

## Part 7 — Virtual WAN

<details>
<summary>Task 1 — Virtual WAN</summary>

```powershell
New-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME -Location $LOCATION_EASTUS -VirtualWANType Standard
Get-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME | Select-Object Name, Location, ProvisioningState
```

</details>

<details>
<summary>Task 2 — Virtual Hub ⏱️ 30 min</summary>

```powershell
New-AzVirtualHub `
  -ResourceGroupName $RG -Name $HUB_NAME `
  -Location $LOCATION_EASTUS `
  -VirtualWan (Get-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME) `
  -AddressPrefix $HUB_PREFIX -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check status periodically until Succeeded
Get-AzVirtualHub -ResourceGroupName $RG -Name $HUB_NAME | Select-Object Name, ProvisioningState
```

</details>

<details>
<summary>Task 3 — Connect ResearchVnet ⛔ only after Hub shows Succeeded</summary>

> ResearchVnet already exists from the ARM template deployment (Task 1) in `southeastasia` — do not recreate it.

```powershell
$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME

New-AzVirtualHubVnetConnection `
  -ResourceGroupName $RG -VirtualHubName $HUB_NAME `
  -Name $VWAN_CONN -RemoteVirtualNetwork $vnet3 -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check status
Get-AzVirtualHubVnetConnection -ResourceGroupName $RG -VirtualHubName $HUB_NAME -Name $VWAN_CONN | Select-Object Name, ProvisioningState
```

</details>
