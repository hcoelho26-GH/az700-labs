# M06 — DDoS, Firewall & Firewall Manager

## Variables

<details>
<summary>Show variables</summary>

```powershell
$LOCATION = "eastus"

$RG_DDOS         = "MyResourceGroup"
$DDOS_PLAN       = "MyDdosProtectionPlan"
$VNET_DDOS       = "MyVirtualNetwork"   ; $VNET_DDOS_PFX   = "10.1.0.0/16"
$SUBNET_DDOS     = "MySubnet"           ; $SUBNET_DDOS_PFX = "10.1.0.0/24"
$PIP_DDOS        = "MyPublicIPAddress"
$PIP_DNS         = "mypublicdns"

$RG_FW         = "Test-FW-RG"
$VNET_FW       = "Test-FW-VN"          ; $VNET_FW_PFX   = "10.0.0.0/16"
$SUBNET_FW     = "AzureFirewallSubnet" ; $SUBNET_FW_PFX = "10.0.1.0/26"
$SUBNET_WL     = "Workload-SN"         ; $SUBNET_WL_PFX = "10.0.2.0/24"
$FW_NAME       = "Test-FW01"
$FW_PIP        = "fw-pip"
$FW_POLICY     = "fw-test-pol"
$ROUTE_TABLE   = "Firewall-route"
$ROUTE_NAME    = "fw-dg"
$SRV_WORK      = "Srv-Work"
$VM_SIZE       = "Standard_DS2_v3"
$ADMIN_USER    = "TestUser"
$APP_RULE_COLL  = "App-Coll01"
$NET_RULE_COLL  = "Net-Coll01"
$DNAT_RULE_COLL = "DNAT-Coll01"

$RG_FM        = "fw-manager-rg"
$VWAN_FM      = "Vwan-Hub"
$HUB_FM       = "Hub-01"            ; $HUB_FM_PFX   = "10.2.0.0/24"
$SPOKE01      = "Spoke-01"          ; $SPOKE01_PFX  = "10.0.0.0/16"
$SPOKE01_SUB  = "Workload-01-SN"    ; $SPOKE01_SPFX = "10.0.1.0/24"
$SPOKE02      = "Spoke-02"          ; $SPOKE02_PFX  = "10.1.0.0/16"
$SPOKE02_SUB  = "Workload-02-SN"    ; $SPOKE02_SPFX = "10.1.1.0/24"
$FW_POLICY_FM = "Policy-01"
$SRV_WL01     = "Srv-workload-01"
$SRV_WL02     = "Srv-workload-02"
```

</details>

---

## Part 4 — DDoS Protection

<details>
<summary>Tasks 1-3 — DDoS Plan + VNet</summary>

```powershell
New-AzResourceGroup -Name $RG_DDOS -Location $LOCATION
$ddosPlan = New-AzDdosProtectionPlan -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $DDOS_PLAN
$subnet   = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_DDOS -AddressPrefix $SUBNET_DDOS_PFX
$vnet     = New-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $VNET_DDOS -AddressPrefix $VNET_DDOS_PFX -Subnet $subnet -DdosProtectionPlan $ddosPlan -EnableDdosProtection
Get-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Name $VNET_DDOS | Select-Object Name, EnableDdosProtection
```

</details>

<details>
<summary>Task 4 — DDoS Telemetry</summary>

```powershell
$pip = New-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $PIP_DDOS -Sku Standard -AllocationMethod Static -DomainNameLabel $PIP_DNS
Get-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Name $PIP_DDOS | Select-Object Name, IpAddress
```

</details>

**Tasks 5-7 — Manual**: Diagnostic logs, alerts and simulation via portal only.

---

## Part 7 — Azure Firewall

<details>
<summary>Tasks 2-4 — VNet + VM + Firewall</summary>

```powershell
New-AzResourceGroup -Name $RG_FW -Location $LOCATION
$subnetFw = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FW -AddressPrefix $SUBNET_FW_PFX
$subnetWl = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_WL -AddressPrefix $SUBNET_WL_PFX
New-AzVirtualNetwork -ResourceGroupName $RG_FW -Location $LOCATION -Name $VNET_FW -AddressPrefix $VNET_FW_PFX -Subnet $subnetFw,$subnetWl

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL).Id
$nic = New-AzNetworkInterface -ResourceGroupName $RG_FW -Location $LOCATION -Name "$SRV_WORK-nic" -SubnetId $subnetId
$vmConfig = New-AzVMConfig -VMName $SRV_WORK -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WORK -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG_FW -Location $LOCATION -VM $vmConfig
$srvWorkIp = (Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name "$SRV_WORK-nic").IpConfigurations[0].PrivateIpAddress

$fwPip      = New-AzPublicIpAddress -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_PIP -Sku Standard -AllocationMethod Static
$fwPolicy   = New-AzFirewallPolicy -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_POLICY
$vnet       = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$fwSub      = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FW
$fwIpConfig = New-AzFirewallIpConfiguration -Name "fwIpConfig" -PublicIPAddress $fwPip -Subnet $fwSub
$firewall   = New-AzFirewall -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_NAME -Sku Standard -FirewallPolicy $fwPolicy -IpConfiguration $fwIpConfig
$fwPrivateIp = $firewall.IpConfigurations[0].PrivateIPAddress
Write-Host "Firewall Private IP: $fwPrivateIp"
Write-Host "Firewall Public IP:  $($fwPip.IpAddress)"
```

</details>

<details>
<summary>Task 5 — Default Route</summary>

```powershell
$routeTable = New-AzRouteTable -ResourceGroupName $RG_FW -Location $LOCATION -Name $ROUTE_TABLE -DisableBgpRoutePropagation $false
$routeTable | Add-AzRouteConfig -Name $ROUTE_NAME -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $fwPrivateIp | Set-AzRouteTable
$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subWl = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL
$subWl.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $vnet
```

</details>

<details>
<summary>Tasks 6-8 — Firewall Rules</summary>

```powershell
$appRule = New-AzFirewallPolicyApplicationRule -Name "Allow-Google" -SourceAddress "10.0.2.0/24" -TargetFqdn "www.google.com" -Protocol "http:80","https:443"
$appColl = New-AzFirewallPolicyFilterRuleCollection -Name $APP_RULE_COLL -Priority 200 -ActionType Allow -Rule $appRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup01" -Priority 200 -RuleCollection $appColl -FirewallPolicyObject $fwPolicy

$netRule = New-AzFirewallPolicyNetworkRule -Name "Allow-DNS" -SourceAddress "10.0.2.0/24" -DestinationAddress "209.244.0.3","209.244.0.4" -DestinationPort "53" -Protocol UDP
$netColl = New-AzFirewallPolicyFilterRuleCollection -Name $NET_RULE_COLL -Priority 200 -ActionType Allow -Rule $netRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup02" -Priority 300 -RuleCollection $netColl -FirewallPolicyObject $fwPolicy

$dnatRule = New-AzFirewallPolicyNatRule -Name "RDP-to-SrvWork" -SourceAddress "*" -DestinationAddress $fwPip.IpAddress -DestinationPort "3389" -Protocol TCP -TranslatedAddress $srvWorkIp -TranslatedPort "3389"
$dnatColl = New-AzFirewallPolicyNatRuleCollection -Name $DNAT_RULE_COLL -Priority 100 -ActionType DNAT -Rule $dnatRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup03" -Priority 100 -RuleCollection $dnatColl -FirewallPolicyObject $fwPolicy
```

</details>

<details>
<summary>Task 9 — Change DNS on Srv-Work NIC</summary>

```powershell
$nic = Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name "$SRV_WORK-nic"
$nic.DnsSettings.DnsServers.Clear()
$nic.DnsSettings.DnsServers.Add("209.244.0.3")
$nic.DnsSettings.DnsServers.Add("209.244.0.4")
Set-AzNetworkInterface -NetworkInterface $nic
```

</details>

**Task 10 — Manual**: RDP to `<FW_PUBLIC_IP>:3389` → `www.google.com` allowed, `www.microsoft.com` blocked.

---

## Part 9 — Firewall Manager

<details>
<summary>Tasks 1-2 — Spoke VNets + Secured Hub ⏱️ 30 min</summary>

```powershell
New-AzResourceGroup -Name $RG_FM -Location $LOCATION
$sub01 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE01_SUB -AddressPrefix $SPOKE01_SPFX
New-AzVirtualNetwork -ResourceGroupName $RG_FM -Location $LOCATION -Name $SPOKE01 -AddressPrefix $SPOKE01_PFX -Subnet $sub01
$sub02 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE02_SUB -AddressPrefix $SPOKE02_SPFX
New-AzVirtualNetwork -ResourceGroupName $RG_FM -Location $LOCATION -Name $SPOKE02 -AddressPrefix $SPOKE02_PFX -Subnet $sub02

$vwan = New-AzVirtualWan -ResourceGroupName $RG_FM -Location $LOCATION -Name $VWAN_FM -VirtualWANType Standard
New-AzVirtualHub -ResourceGroupName $RG_FM -Location $LOCATION -Name $HUB_FM -VirtualWan $vwan -AddressPrefix $HUB_FM_PFX -Sku Standard
Get-AzVirtualHub -ResourceGroupName $RG_FM -Name $HUB_FM | Select-Object Name, ProvisioningState
```

</details>

<details>
<summary>Task 3 — Connect Spokes ⛔ only after Hub shows Succeeded</summary>

```powershell
$spoke01Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$spoke02Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02
New-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM -Name "hub-spoke-01" -RemoteVirtualNetwork $spoke01Vnet
New-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM -Name "hub-spoke-02" -RemoteVirtualNetwork $spoke02Vnet
```

</details>

<details>
<summary>Task 4 — Deploy Workload Servers</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet01     = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$subnetId01 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet01 -Name $SPOKE01_SUB).Id
$nic01 = New-AzNetworkInterface -ResourceGroupName $RG_FM -Location $LOCATION -Name "$SRV_WL01-nic" -SubnetId $subnetId01
$vmConfig01 = New-AzVMConfig -VMName $SRV_WL01 -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WL01 -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic01.Id
New-AzVM -ResourceGroupName $RG_FM -Location $LOCATION -VM $vmConfig01 -AsJob

$vnet02     = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02
$subnetId02 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet02 -Name $SPOKE02_SUB).Id
$nic02 = New-AzNetworkInterface -ResourceGroupName $RG_FM -Location $LOCATION -Name "$SRV_WL02-nic" -SubnetId $subnetId02
$vmConfig02 = New-AzVMConfig -VMName $SRV_WL02 -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WL02 -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic02.Id
New-AzVM -ResourceGroupName $RG_FM -Location $LOCATION -VM $vmConfig02 -AsJob

Get-Job | Wait-Job
$wl01Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name "$SRV_WL01-nic").IpConfigurations[0].PrivateIpAddress
$wl02Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name "$SRV_WL02-nic").IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-workload-01 IP: $wl01Ip"
Write-Host "Srv-workload-02 IP: $wl02Ip"
```

</details>

<details>
<summary>Task 5 — Firewall Policy</summary>

```powershell
$fwPolicy = New-AzFirewallPolicy -ResourceGroupName $RG_FM -Location $LOCATION -Name $FW_POLICY_FM
$appRule  = New-AzFirewallPolicyApplicationRule -Name "Allow-Microsoft" -SourceAddress "10.0.1.0/24","10.1.1.0/24" -TargetFqdn "www.microsoft.com" -Protocol "http:80","https:443"
$appColl  = New-AzFirewallPolicyFilterRuleCollection -Name "App-Coll01" -Priority 200 -ActionType Allow -Rule $appRule
$netRule1 = New-AzFirewallPolicyNetworkRule -Name "Allow-RDP-Wl01" -SourceAddress "*" -DestinationAddress "10.0.1.4" -DestinationPort "3389" -Protocol TCP
$netRule2 = New-AzFirewallPolicyNetworkRule -Name "Allow-RDP-Wl02" -SourceAddress "*" -DestinationAddress "10.1.1.4" -DestinationPort "3389" -Protocol TCP
$netColl  = New-AzFirewallPolicyFilterRuleCollection -Name "Net-Coll01" -Priority 100 -ActionType Allow -Rule @($netRule1,$netRule2)
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FM -Name $FW_POLICY_FM
New-AzFirewallPolicyRuleCollectionGroup -Name "PolicyRuleGroup" -Priority 100 -RuleCollection @($appColl,$netColl) -FirewallPolicyObject $fwPolicy
```

</details>

**Tasks 6-7 — Manual (portal only)**: Associate policy in Firewall Manager → enable Internet + Private traffic routing on hub connections.

**Tasks 8-9 — Manual**: RDP into Srv-workload-01 → `www.microsoft.com` works, `www.google.com` blocked → `mstsc` to `10.1.1.4` succeeds.
