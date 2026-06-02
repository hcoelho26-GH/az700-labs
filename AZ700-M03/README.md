# M03 — ExpressRoute

## Variables

<details>
<summary>Show variables</summary>

```powershell
$RG_CORE   = "ContosoResourceGroup"
$RG_ER     = "ExpressRouteResourceGroup"
$LOCATION  = "eastus"
$LOCATION2 = "eastus2"

$VNET_NAME   = "CoreServicesVNet"           ; $VNET_PREFIX = "10.20.0.0/16"
$GW_SUB_NAME = "GatewaySubnet"              ; $GW_SUB      = "10.20.0.0/27"
$GW_NAME     = "CoreServicesVnetGateway"
$GW_PIP      = "CoreServicesVnetGateway-ip"
$GW_SKU      = "Standard"

$ER_NAME     = "TestERCircuit"
$ER_LOCATION = "eastus2"
$ER_PEERING  = "Seattle"
$ER_PROVIDER = "Equinix"
$ER_BW       = 50
$ER_SKU      = "Standard"
$ER_BILLING  = "MeteredData"
```

</details>

---

## Part 4 — ExpressRoute Gateway

<details>
<summary>Task 1 — VNet + GatewaySubnet</summary>

```powershell
New-AzResourceGroup -Name $RG_CORE -Location $LOCATION

$gwSub = New-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -AddressPrefix $GW_SUB

New-AzVirtualNetwork `
  -ResourceGroupName $RG_CORE -Location $LOCATION `
  -Name $VNET_NAME -AddressPrefix $VNET_PREFIX `
  -Subnet $gwSub

Get-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME) |
  Select-Object Name, AddressPrefix
```

</details>

<details>
<summary>Task 2 — ExpressRoute Gateway ⏱️ 45 min</summary>

> GatewayType `ExpressRoute` — different from the VPN Gateway in M02.

```powershell
$pipGw = New-AzPublicIpAddress `
  -ResourceGroupName $RG_CORE -Location $LOCATION `
  -Name $GW_PIP -Sku Standard -AllocationMethod Static

$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME
$gwSub = Get-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -VirtualNetwork $vnet
$gwIp  = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig" -SubnetId $gwSub.Id -PublicIpAddressId $pipGw.Id

New-AzVirtualNetworkGateway `
  -ResourceGroupName $RG_CORE -Location $LOCATION `
  -Name $GW_NAME -IpConfigurations $gwIp `
  -GatewayType ExpressRoute -GatewaySku $GW_SKU -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check status periodically until Succeeded
Get-AzVirtualNetworkGateway -ResourceGroupName $RG_CORE -Name $GW_NAME | Select-Object Name, GatewayType, ProvisioningState
```

</details>

---

## Part 5 — ExpressRoute Circuit

<details>
<summary>Task 1 — Create Circuit ⚠️ billing starts immediately</summary>

```powershell
New-AzResourceGroup -Name $RG_ER -Location $LOCATION2

New-AzExpressRouteCircuit `
  -ResourceGroupName $RG_ER -Location $ER_LOCATION `
  -Name $ER_NAME -SkuFamily $ER_BILLING -SkuTier $ER_SKU `
  -ServiceProviderName $ER_PROVIDER `
  -PeeringLocation $ER_PEERING `
  -BandwidthInMbps $ER_BW
```

</details>

<details>
<summary>Task 2 — Get Service Key</summary>

```powershell
$circuit = Get-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME
Write-Host "Service Key: $($circuit.ServiceKey)"
Write-Host "Provider Status: $($circuit.ServiceProviderProvisioningState)"
Write-Host "Circuit Status: $($circuit.CircuitProvisioningState)"
```

</details>

<details>
<summary>Task 3 — Deprovision ⛔ only after ProviderStatus = NotProvisioned</summary>

> Billing continues until the provider deprovisions the circuit. Do not delete before `ProviderStatus = NotProvisioned`.

```powershell
Remove-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME -Force

Remove-AzResourceGroup -Name $RG_CORE -Force -AsJob
Remove-AzResourceGroup -Name $RG_ER   -Force -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
```

</details>
