# AZ-700 Lab Reference

> Quick reference for PowerShell commands used in AZ-700 labs.  
> **Always run the Variables block first in each session.**

---

## Table of Contents

### Global Variables
| Module | Contents |
|--------|----------|
| [Variables M01](#variables-m01) | RG · VNets · DNS · VMs · Peerings |
| [Variables M02](#variables-m02) | VNets · Gateways · Connections · VWAN |
| [Variables M03](#variables-m03) | VNet · ER Gateway · ER Circuit |

### M01 — Virtual Networks, DNS & Peering
| Part | Task | Description |
|------|------|-------------|
| Part 4 | Tasks 1-4 | [Create VNets & Subnets](#m01--part-4--create-vnets--subnets) |
| Part 4 | Task 5 | [Verify VNets](#m01--part-4--verify-vnets) |
| Part 6 | Task 1 | [Private DNS Zone](#m01--part-6--private-dns-zone) |
| Part 6 | Task 2 | [VNet Link](#m01--part-6--vnet-link) |
| Part 6 | Tasks 3-4 | [testvm1 + testvm2](#m01--part-6--testvm1--testvm2) |
| Part 6 | Task 5 | [Verify DNS](#m01--part-6--verify-dns) |
| Part 8 | Task 1 | [ManufacturingVM](#m01--part-8--manufacturingvm) |
| Part 8 | Task 2 | [RDP + Tests](#m01--part-8--rdp--tests) ⚠️ manual |
| Part 8 | Tasks 3-4 | [VNet Peering](#m01--part-8--vnet-peering) |

### M02 — VPN Gateway & Virtual WAN
| Part | Task | Description |
|------|------|-------------|
| Part 3 | Tasks 1-3 | [Create VNets](#m02--part-3--create-vnets) |
| Part 3 | Tasks 4-5 | [CoreServicesVM + MfgVM](#m02--part-3--coreservicesvm--mfgvm) |
| Part 3 | Tasks 6-7 | [RDP + Tests](#m02--part-3--rdp--tests) ⚠️ manual |
| Part 3 | Tasks 6-7 | [VPN Gateways](#m02--part-3--vpn-gateways) ⏱️ 45 min |
| Part 3 | Tasks 8-9 | [VPN Connections](#m02--part-3--vpn-connections) |
| Part 7 | Task 1 | [Virtual WAN](#m02--part-7--virtual-wan) |
| Part 7 | Task 2 | [Virtual Hub](#m02--part-7--virtual-hub) ⏱️ 30 min |
| Part 7 | Task 3 | [Connect ResearchVnet](#m02--part-7--connect-researchvnet-to-hub) |

### M03 — ExpressRoute
| Part | Task | Description |
|------|------|-------------|
| Part 4 | Task 1 | [VNet + GatewaySubnet](#m03--part-4--vnet--gatewaysubnet) |
| Part 4 | Task 2 | [ExpressRoute Gateway](#m03--part-4--expressroute-gateway) ⏱️ 45 min |
| Part 5 | Task 1 | [ExpressRoute Circuit](#m03--part-5--expressroute-circuit) ⚠️ billing starts |
| Part 5 | Task 2 | [Service Key](#m03--part-5--service-key) |
| Part 5 | Task 3 | [Deprovision + Cleanup](#m03--part-5--deprovision--cleanup) ⛔ caution |

---

## Variables M01

> Run this block first. Variables do not persist when you close the terminal.

```powershell
# General
$RG                 = "ContosoResourceGrouplod61979644"
$LOCATION_EASTUS    = "eastus"
$LOCATION_WESTEU    = "westeurope"
$LOCATION_SOUTHASIA = "southeastasia"

# CoreServicesVnet
$VNET1_NAME      = "CoreServicesVnet"       ; $VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_SUB1_NAME = "GatewaySubnet"          ; $VNET1_SUB1      = "10.20.0.0/27"
$VNET1_SUB2_NAME = "DatabaseSubnet"         ; $VNET1_SUB2      = "10.20.20.0/24"
$VNET1_SUB3_NAME = "SharedServicesSubnet"   ; $VNET1_SUB3      = "10.20.10.0/24"
$VNET1_SUB4_NAME = "PublicWebServiceSubnet" ; $VNET1_SUB4      = "10.20.30.0/24"

# ManufacturingVnet
$VNET2_NAME      = "ManufacturingVnet"          ; $VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"  ; $VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"              ; $VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"              ; $VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"              ; $VNET2_SUB4      = "10.30.22.0/24"

# ResearchVnet
$VNET3_NAME      = "ResearchVnet"         ; $VNET3_PREFIX    = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet" ; $VNET3_SUB1      = "10.40.0.0/24"

# DNS
$DNS_ZONE      = "Contoso.com"
$DNS_LINK_NAME = "CoreServicesVnetLink"

# VMs Part 6
$VM1_NAME = "testvm1" ; $NIC1_NAME = "testvm1-nic" ; $NSG1_NAME = "testvm1-nsg" ; $PIP1_NAME = "testvm1-pip"
$VM2_NAME = "testvm2" ; $NIC2_NAME = "testvm2-nic" ; $NSG2_NAME = "testvm2-nsg" ; $PIP2_NAME = "testvm2-pip"

# VM Part 8
$MFG_VM_NAME     = "ManufacturingVM"           ; $MFG_SUBNET_NAME = "ManufacturingSystemSubnet"
$MFG_NIC_NAME    = "ManufacturingVM-nic"
$MFG_NSG_NAME    = "ManufacturingVM-nsg"
$MFG_PIP_NAME    = "ManufacturingVM-pip"

# Peerings Part 8
$PEERING1_NAME = "CoreServicesVnet-to-ManufacturingVnet"
$PEERING2_NAME = "ManufacturingVnet-to-CoreServicesVnet"

$VM_SIZE    = "Standard_D2s_v3"
$ADMIN_USER = "TestUser"
```

---

## Variables M02

> Run this block first in any M02 session.

```powershell
# General
$RG              = "ContosoResourceGroup"
$LOCATION_EASTUS = "eastus"
$LOCATION_WESTEU = "westeurope"

# CoreServicesVnet
$VNET1_NAME      = "CoreServicesVnet"       ; $VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_GW_NAME   = "GatewaySubnet"          ; $VNET1_GW        = "10.20.0.0/27"
$VNET1_SUB1_NAME = "DatabaseSubnet"         ; $VNET1_SUB1      = "10.20.20.0/24"
$VNET1_SUB2_NAME = "SharedServicesSubnet"   ; $VNET1_SUB2      = "10.20.10.0/24"
$VNET1_SUB3_NAME = "PublicWebServiceSubnet" ; $VNET1_SUB3      = "10.20.30.0/24"

# ManufacturingVnet
$VNET2_NAME      = "ManufacturingVnet"          ; $VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_GW_NAME   = "GatewaySubnet"              ; $VNET2_GW        = "10.30.0.0/27"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"  ; $VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"              ; $VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"              ; $VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"              ; $VNET2_SUB4      = "10.30.22.0/24"

# ResearchVnet
$VNET3_NAME      = "ResearchVnet"         ; $VNET3_PREFIX    = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet" ; $VNET3_SUB1      = "10.40.0.0/24"

# VPN Gateways
$GW1_NAME   = "CoreServicesVnetGateway"  ; $GW1_PIP = "CoreServicesVnetGateway-ip"
$GW2_NAME   = "ManufacturingVnetGateway" ; $GW2_PIP = "ManufacturingVnetGateway-ip"
$GW_SKU     = "VpnGw1AZ"                 ; $GW_GEN  = "Generation1"

# VPN Connections
$CONN1_NAME = "CoreServicesGW-to-ManufacturingGW"
$CONN2_NAME = "ManufacturingGW-to-CoreServicesGW"
$SHARED_KEY = "abc123"

# VMs
$VM1_NAME = "CoreServicesVM"  ; $VM1_NIC = "CoreServicesVM-nic"  ; $VM1_NSG = "CoreServicesVM-nsg"  ; $VM1_PIP = "CoreServicesVM-pip"
$VM2_NAME = "ManufacturingVM" ; $VM2_NIC = "ManufacturingVM-nic" ; $VM2_NSG = "ManufacturingVM-nsg" ; $VM2_PIP = "ManufacturingVM-pip"
$VM_SIZE    = "Standard_D2s_v3" ; $ADMIN_USER = "TestUser"

# Virtual WAN
$VWAN_NAME  = "ContosoVirtualWAN" ; $HUB_NAME  = "ContosoHub"
$HUB_PREFIX = "10.60.0.0/24"      ; $VWAN_CONN = "ContosoVirtualWAN-to-ResearchVNet"
```

---

## Variables M03

> Run this block first in any M03 session.

```powershell
# General
$RG_CORE  = "ContosoResourceGroup"
$RG_ER    = "ExpressRouteResourceGroup"
$LOCATION = "eastus"
$LOCATION2= "eastus2"

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
```

---

## M01 · Part 4 · Create VNets & Subnets

> Resource Group + 3 VNets in different regions.

```powershell
# Resource Group
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS
Get-AzResourceGroup -Name $RG
```

```powershell
# CoreServicesVnet — East US
$gw  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB4_NAME -AddressPrefix $VNET1_SUB4
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX -Subnet $gw,$db,$ss,$web
```

---

## M01 · Part 4 · Verify VNets

```powershell
Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location, AddressSpace
```

---

## M01 · Part 6 · Private DNS Zone

```powershell
New-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
Get-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
```

---

## M01 · Part 6 · VNet Link

```powershell
$vnet1 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG -ZoneName $DNS_ZONE -Name $DNS_LINK_NAME -VirtualNetworkId $vnet1.Id -EnableRegistration
Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG -ZoneName $DNS_ZONE -Name $DNS_LINK_NAME
```

---

## M01 · Part 6 · testvm1 + testvm2

```powershell
$cred = Get-Credential -UserName $ADMIN_USER

# testvm1 — SharedServicesSubnet
$vnet1   = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$subnet1 = Get-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -VirtualNetwork $vnet1
$nsg1    = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NSG1_NAME
$pip1    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $PIP1_NAME -AllocationMethod Dynamic
$nic1    = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NIC1_NAME -SubnetId $subnet1.Id -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
$vmCfg1  = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE |
           Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $cred |
           Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
           Add-AzVMNetworkInterface -Id $nic1.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vmCfg1
```

---

## M01 · Part 6 · Verify DNS

```powershell
Get-AzPrivateDnsRecordSet -ResourceGroupName $RG -ZoneName $DNS_ZONE -RecordType A
```

---

## M01 · Part 8 · ManufacturingVM

```powershell
$cred    = Get-Credential -UserName $ADMIN_USER
$vnet2   = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$subnet  = Get-AzVirtualNetworkSubnetConfig -Name $MFG_SUBNET_NAME -VirtualNetwork $vnet2
$nsg     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_NSG_NAME
$pip     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_PIP_NAME -AllocationMethod Dynamic
$nic     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_NIC_NAME -SubnetId $subnet.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id
$vmCfg   = New-AzVMConfig -VMName $MFG_VM_NAME -VMSize $VM_SIZE |
           Set-AzVMOperatingSystem -Windows -ComputerName $MFG_VM_NAME -Credential $cred |
           Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
           Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_WESTEU -VM $vmCfg
```

---

## M01 · Part 8 · RDP + Tests

> ⚠️ **Manual step** — requires RDP into the VM to test connectivity before creating the peering.

---

## M01 · Part 8 · VNet Peering

```powershell
$vnet1 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME

Add-AzVirtualNetworkPeering -Name $PEERING1_NAME -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.Id
Add-AzVirtualNetworkPeering -Name $PEERING2_NAME -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.Id

Get-AzVirtualNetworkPeering -ResourceGroupName $RG -VirtualNetworkName $VNET1_NAME | Select-Object Name, PeeringState
Get-AzVirtualNetworkPeering -ResourceGroupName $RG -VirtualNetworkName $VNET2_NAME | Select-Object Name, PeeringState
```

---

## M02 · Part 3 · Create VNets

```powershell
# CoreServicesVnet
$gw1  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_GW_NAME  -AddressPrefix $VNET1_GW
$db1  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$ss1  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$web1 = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX -Subnet $gw1,$db1,$ss1,$web1

# ManufacturingVnet
$gw2  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_GW_NAME  -AddressPrefix $VNET2_GW
$mfg2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$s1   = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$s2   = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$s3   = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VNET2_NAME -AddressPrefix $VNET2_PREFIX -Subnet $gw2,$mfg2,$s1,$s2,$s3
```

---

## M02 · Part 3 · CoreServicesVM + MfgVM

```powershell
$cred = Get-Credential -UserName $ADMIN_USER

# CoreServicesVM
$vnet1   = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$subnet1 = Get-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -VirtualNetwork $vnet1
$nsg1    = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NSG
$pip1    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_PIP -AllocationMethod Dynamic
$nic1    = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NIC -SubnetId $subnet1.Id -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
$vmCfg1  = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE |
           Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $cred |
           Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
           Add-AzVMNetworkInterface -Id $nic1.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vmCfg1
```

---

## M02 · Part 3 · RDP + Tests

> ⚠️ **Manual step** — requires RDP into the VMs to test connectivity before creating the gateways.

---

## M02 · Part 3 · VPN Gateways

> ⏱️ Takes up to 45 minutes. Run both in parallel.

```powershell
# CoreServicesVnetGateway — East US
$pipGw1    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$gwSubnet1 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
$gwIp1     = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig1" -SubnetId $gwSubnet1.Id -PublicIpAddressId $pipGw1.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_NAME -IpConfigurations $gwIp1 -GatewayType VPN -VpnType RouteBased -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN

# ManufacturingVnetGateway — West EU
$pipGw2    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$gwSubnet2 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2
$gwIp2     = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig2" -SubnetId $gwSubnet2.Id -PublicIpAddressId $pipGw2.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_NAME -IpConfigurations $gwIp2 -GatewayType VPN -VpnType RouteBased -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN

# Check status
Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME | Select-Object Name, ProvisioningState
Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME | Select-Object Name, ProvisioningState
```

---

## M02 · Part 3 · VPN Connections

> ⛔ **Only run after both gateways show `Succeeded`!**

```powershell
$gw1Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME
$gw2Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME

New-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $CONN1_NAME -ConnectionType Vnet2Vnet -VirtualNetworkGateway1 $gw1Obj -VirtualNetworkGateway2 $gw2Obj -SharedKey $SHARED_KEY -EnableBgp $false
New-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $CONN2_NAME -ConnectionType Vnet2Vnet -VirtualNetworkGateway1 $gw2Obj -VirtualNetworkGateway2 $gw1Obj -SharedKey $SHARED_KEY -EnableBgp $false

Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN1_NAME | Select-Object Name, ConnectionStatus
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN2_NAME | Select-Object Name, ConnectionStatus
```

---

## M02 · Part 7 · Virtual WAN

```powershell
New-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME -Location $LOCATION_EASTUS -VirtualWANType Standard
Get-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME | Select-Object Name, Location, ProvisioningState
```

---

## M02 · Part 7 · Virtual Hub

> ⏱️ Takes up to 30 minutes. Do not connect the VNet until the Hub shows `Succeeded`.

```powershell
New-AzVirtualHub `
  -ResourceGroupName $RG `
  -Name $HUB_NAME `
  -Location $LOCATION_EASTUS `
  -VirtualWan (Get-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME) `
  -AddressPrefix $HUB_PREFIX

Get-AzVirtualHub -ResourceGroupName $RG -Name $HUB_NAME | Select-Object Name, ProvisioningState
```

---

## M02 · Part 7 · Connect ResearchVnet to Hub

> ⛔ **Only run after the Hub shows `Succeeded`!**

```powershell
$res   = New-AzVirtualNetworkSubnetConfig -Name $VNET3_SUB1_NAME -AddressPrefix $VNET3_SUB1
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET3_NAME -AddressPrefix $VNET3_PREFIX -Subnet $res
$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME
New-AzVirtualHubVnetConnection -ResourceGroupName $RG -VirtualHubName $HUB_NAME -Name $VWAN_CONN -RemoteVirtualNetwork $vnet3
Get-AzVirtualHubVnetConnection -ResourceGroupName $RG -VirtualHubName $HUB_NAME -Name $VWAN_CONN | Select-Object Name, ProvisioningState
```

---

## M03 · Part 4 · VNet + GatewaySubnet

> Creates the CoreServicesVNet with GatewaySubnet for the ExpressRoute Gateway.

```powershell
New-AzResourceGroup -Name $RG_CORE -Location $LOCATION
$gwSub = New-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -AddressPrefix $GW_SUB
New-AzVirtualNetwork -ResourceGroupName $RG_CORE -Location $LOCATION -Name $VNET_NAME -AddressPrefix $VNET_PREFIX -Subnet $gwSub
Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME) | Select-Object Name, AddressPrefix
```

---

## M03 · Part 4 · ExpressRoute Gateway

> ⏱️ Takes up to 45 minutes. GatewayType `ExpressRoute` — different from the VPN Gateway in M02. SKU Standard.

```powershell
$pipGw = New-AzPublicIpAddress -ResourceGroupName $RG_CORE -Location $LOCATION -Name $GW_PIP -Sku Standard -AllocationMethod Static
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
```

---

## M03 · Part 5 · ExpressRoute Circuit

> ⚠️ **Billing starts as soon as the Service Key is issued!**

```powershell
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
```

---

## M03 · Part 5 · Service Key

> The Service Key is what you send to the connectivity provider to provision the circuit.

```powershell
$circuit = Get-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME
Write-Host "Service Key: $($circuit.ServiceKey)"
Write-Host "Provider Status: $($circuit.ServiceProviderProvisioningState)"
Write-Host "Circuit Status: $($circuit.CircuitProvisioningState)"
```

---

## M03 · Part 5 · Deprovision + Cleanup

> ⛔ **Only delete after the provider shows `ProviderStatus = NotProvisioned`. You will keep being billed until then!**

```powershell
# Delete the circuit
Remove-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME -Force

# Cleanup — delete Resource Groups
Remove-AzResourceGroup -Name $RG_CORE -Force -AsJob
Remove-AzResourceGroup -Name $RG_ER   -Force -AsJob
```

---

*AZ-700 · Designing and Implementing Microsoft Azure Networking Solutions*
