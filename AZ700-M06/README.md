# M06 — DDoS, Firewall & Firewall Manager

## Variables

<details>
<summary>Show variables</summary>

```powershell
$LOCATION = "eastus"

# Part 4 — DDoS
$RG_DDOS         = "MyResourceGroup"
$DDOS_PLAN       = "MyDdosProtectionPlan"
$VNET_DDOS       = "MyVirtualNetwork"   ; $VNET_DDOS_PFX  = "10.1.0.0/16"
$SUBNET_DDOS     = "MySubnet"           ; $SUBNET_DDOS_PFX = "10.1.0.0/24"
$PIP_DDOS        = "MyPublicIPAddress"
$PIP_DNS         = "mypublicdns"

# Part 7 — Firewall
$RG_FW           = "Test-FW-RG"
$VNET_FW         = "Test-FW-VN"         ; $VNET_FW_PFX   = "10.0.0.0/16"
$SUBNET_FW       = "AzureFirewallSubnet" ; $SUBNET_FW_PFX = "10.0.1.0/26"
$SUBNET_WL       = "Workload-SN"         ; $SUBNET_WL_PFX = "10.0.2.0/24"
$FW_NAME         = "Test-FW01"
$FW_PIP          = "fw-pip"
$FW_POLICY       = "fw-test-pol"
$ROUTE_TABLE     = "Firewall-route"
$ROUTE_NAME      = "fw-dg"
$SRV_WORK        = "Srv-Work"
$SRV_WORK_NIC    = "Srv-Work-nic"        # ARM template naming (firewall_parameters.json)
$APP_RULE_COLL   = "App-Coll01"
$NET_RULE_COLL   = "Net-Coll01"
$DNAT_RULE_COLL  = "DNAT-Coll01"
$VM_SIZE         = "Standard_DS2_v3"
$ADMIN_USER      = "TestUser"

# Part 9 — Firewall Manager
$RG_FM        = "fw-manager-rg"
$VWAN_FM      = "Vwan-Hub"
$HUB_FM       = "Hub-01"            ; $HUB_FM_PFX   = "10.2.0.0/24"
$SPOKE01      = "Spoke-01"          ; $SPOKE01_PFX  = "10.0.0.0/16"
$SPOKE01_SUB  = "Workload-01-SN"    ; $SPOKE01_SPFX = "10.0.1.0/24"
$SPOKE02      = "Spoke-02"          ; $SPOKE02_PFX  = "10.1.0.0/16"
$SPOKE02_SUB  = "Workload-02-SN"    ; $SPOKE02_SPFX = "10.1.1.0/24"
$FW_POLICY_FM = "Policy-01"
$SRV_WL01     = "Srv-workload-01"
$SRV_WL01_NIC = "Srv-workload-01nic" # ARM template naming (sem hífen!)
$SRV_WL02     = "Srv-workload-02"
$SRV_WL02_NIC = "Srv-workload-02nic" # ARM template naming (sem hífen!)
```

</details>

---

## Part 4 — DDoS Protection

### Tasks 1-2 — RG + DDoS Plan + VNet

```powershell
New-AzResourceGroup -Name $RG_DDOS -Location $LOCATION

$ddosPlan = New-AzDdosProtectionPlan -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $DDOS_PLAN
$subnet   = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_DDOS -AddressPrefix $SUBNET_DDOS_PFX
$vnet     = New-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $VNET_DDOS -AddressPrefix $VNET_DDOS_PFX -Subnet $subnet -DdosProtectionPlan $ddosPlan -EnableDdosProtection

Get-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Name $VNET_DDOS | Select-Object Name, EnableDdosProtection
```

### Task 3 — VM via ARM ⚠️ LearnOnDemand bloqueia criação de VM por PS

> Upload `ddos.json` + `ddos_parameters.json` para o Cloud Shell, depois:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG_DDOS `
  -Name "deploy-ddos-vm" `
  -TemplateFile ddos.json `
  -TemplateParameterFile ddos_parameters.json `
  -adminPassword (Read-Host "VM Password" -AsSecureString) `
  -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
Get-AzResourceGroupDeployment -ResourceGroupName $RG_DDOS | Select-Object DeploymentName, ProvisioningState
```

> ⚠️ ARM usa subnet `default` — mas o lab criou `MySubnet`. Verifica no portal se o ARM encontra a subnet correcta. Se falhar, recria o ARM apontando para `MySubnet`.

### Task 4 — Public IP para telemetria DDoS

```powershell
$pip = New-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $PIP_DDOS -Sku Standard -AllocationMethod Static -DomainNameLabel $PIP_DNS
Get-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Name $PIP_DDOS | Select-Object Name, IpAddress
```

**Tasks 5-7 — Portal obrigatório**: Diagnostic settings, metric alert e simulação DDoS (BreakingPoint Cloud).

---

## Part 7 — Azure Firewall

### Task 2 — RG + VNet + Subnets

```powershell
New-AzResourceGroup -Name $RG_FW -Location $LOCATION

$subnetFw = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FW -AddressPrefix $SUBNET_FW_PFX
$subnetWl = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_WL -AddressPrefix $SUBNET_WL_PFX
New-AzVirtualNetwork -ResourceGroupName $RG_FW -Location $LOCATION -Name $VNET_FW -AddressPrefix $VNET_FW_PFX -Subnet $subnetFw,$subnetWl

Get-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW) |
  Select-Object Name, AddressPrefix
```

### Task 3 — Srv-Work VM via ARM ⚠️ LearnOnDemand bloqueia criação de VM por PS

> Upload `firewall.json` + `firewall_parameters.json` para o Cloud Shell, depois:  
> 💡 Corre em paralelo com a criação do Firewall (Task 4) — não dependem um do outro.

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG_FW `
  -Name "deploy-fw-vm" `
  -TemplateFile firewall.json `
  -TemplateParameterFile firewall_parameters.json `
  -adminPassword (Read-Host "VM Password" -AsSecureString) `
  -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
Get-AzResourceGroupDeployment -ResourceGroupName $RG_FW | Select-Object DeploymentName, ProvisioningState
```

### Task 4 — Firewall + Policy

```powershell
$fwPip      = New-AzPublicIpAddress -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_PIP -Sku Standard -AllocationMethod Static
$fwPolicy   = New-AzFirewallPolicy -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_POLICY
$vnet       = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$fwSub      = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FW
$fwIpConfig = New-AzFirewallIpConfiguration -Name "fwIpConfig" -PublicIPAddress $fwPip -Subnet $fwSub
$firewall   = New-AzFirewall -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_NAME -Sku Standard -FirewallPolicy $fwPolicy -IpConfiguration $fwIpConfig

# Captura IPs — OBRIGATÓRIO antes de criar as regras DNAT e a route
$fwPrivateIp = $firewall.IpConfigurations[0].PrivateIPAddress
$fwPublicIp  = (Get-AzPublicIpAddress -ResourceGroupName $RG_FW -Name $FW_PIP).IpAddress
Write-Host "Firewall Private IP: $fwPrivateIp"
Write-Host "Firewall Public IP:  $fwPublicIp"
```

### Captura IP da Srv-Work ⛔ só depois do ARM deploy = Succeeded

```powershell
# NIC name vem do firewall_parameters.json: "Srv-Work-nic"
$srvWorkIp = (Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name $SRV_WORK_NIC).IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-Work Private IP: $srvWorkIp"
```

### Task 5 — Default Route (força tráfego pelo Firewall)

```powershell
$routeTable = New-AzRouteTable -ResourceGroupName $RG_FW -Location $LOCATION -Name $ROUTE_TABLE -DisableBgpRoutePropagation $false
$routeTable | Add-AzRouteConfig -Name $ROUTE_NAME -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $fwPrivateIp | Set-AzRouteTable

$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subWl = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL
$subWl.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $vnet
```

### Tasks 6-8 — Regras do Firewall

<details>
<summary>App Rule — Allow Google</summary>

```powershell
$appRule = New-AzFirewallPolicyApplicationRule -Name "Allow-Google" -SourceAddress "10.0.2.0/24" -TargetFqdn "www.google.com" -Protocol "http:80","https:443"
$appColl = New-AzFirewallPolicyFilterRuleCollection -Name $APP_RULE_COLL -Priority 200 -ActionType Allow -Rule $appRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup01" -Priority 200 -RuleCollection $appColl -FirewallPolicyObject $fwPolicy
```

</details>

<details>
<summary>Network Rule — Allow DNS</summary>

```powershell
$netRule = New-AzFirewallPolicyNetworkRule -Name "Allow-DNS" -SourceAddress "10.0.2.0/24" -DestinationAddress "209.244.0.3","209.244.0.4" -DestinationPort "53" -Protocol UDP
$netColl = New-AzFirewallPolicyFilterRuleCollection -Name $NET_RULE_COLL -Priority 200 -ActionType Allow -Rule $netRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup02" -Priority 300 -RuleCollection $netColl -FirewallPolicyObject $fwPolicy
```

</details>

<details>
<summary>DNAT Rule — RDP via Firewall Public IP → Srv-Work</summary>

```powershell
$dnatRule = New-AzFirewallPolicyNatRule -Name "RDP-to-SrvWork" -SourceAddress "*" -DestinationAddress $fwPublicIp -DestinationPort "3389" -Protocol TCP -TranslatedAddress $srvWorkIp -TranslatedPort "3389"
$dnatColl = New-AzFirewallPolicyNatRuleCollection -Name $DNAT_RULE_COLL -Priority 100 -ActionType DNAT -Rule $dnatRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup03" -Priority 100 -RuleCollection $dnatColl -FirewallPolicyObject $fwPolicy
```

</details>

### Task 9 — DNS da NIC da Srv-Work (aponta para DNS externos)

```powershell
$nic = Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name $SRV_WORK_NIC
$nic.DnsSettings.DnsServers.Clear()
$nic.DnsSettings.DnsServers.Add("209.244.0.3")
$nic.DnsSettings.DnsServers.Add("209.244.0.4")
Set-AzNetworkInterface -NetworkInterface $nic
```

**Task 10 — Manual**: RDP para `<fwPublicIp>:3389` → browser dentro da VM → `www.google.com` ✅ → `www.microsoft.com` ❌

```powershell
# Confirma o Public IP do Firewall
Write-Host "RDP target: $fwPublicIp`:3389"
```

---

## Part 9 — Firewall Manager

### Tasks 1-2 — Spoke VNets + VWAN + Hub ⏱️ Hub leva ~30 min

> 💡 Lança o Hub em `-AsJob` e usa o tempo de espera para o deploy das VMs.

```powershell
New-AzResourceGroup -Name $RG_FM -Location $LOCATION

$sub01 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE01_SUB -AddressPrefix $SPOKE01_SPFX
New-AzVirtualNetwork -ResourceGroupName $RG_FM -Location $LOCATION -Name $SPOKE01 -AddressPrefix $SPOKE01_PFX -Subnet $sub01

$sub02 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE02_SUB -AddressPrefix $SPOKE02_SPFX
New-AzVirtualNetwork -ResourceGroupName $RG_FM -Location $LOCATION -Name $SPOKE02 -AddressPrefix $SPOKE02_PFX -Subnet $sub02

$vwan = New-AzVirtualWan -ResourceGroupName $RG_FM -Location $LOCATION -Name $VWAN_FM -VirtualWANType Standard
New-AzVirtualHub -ResourceGroupName $RG_FM -Location $LOCATION -Name $HUB_FM -VirtualWan $vwan -AddressPrefix $HUB_FM_PFX -Sku Standard -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Verifica periodicamente até Succeeded (~30 min)
Get-AzVirtualHub -ResourceGroupName $RG_FM -Name $HUB_FM | Select-Object Name, ProvisioningState
```

### Task 4 — VMs via ARM (corre enquanto o Hub provisiona)

> Upload `FirewallManager.json` + `FirewallManager_parameters.json` para o Cloud Shell, depois:  
> ⚠️ Os NICs no ARM **não têm hífen**: `Srv-workload-01nic` e `Srv-workload-02nic`

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG_FM `
  -Name "deploy-fm-vms" `
  -TemplateFile FirewallManager.json `
  -TemplateParameterFile FirewallManager_parameters.json `
  -adminPassword (Read-Host "VM Password" -AsSecureString) `
  -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
Get-AzResourceGroupDeployment -ResourceGroupName $RG_FM | Select-Object DeploymentName, ProvisioningState
```

### Captura IPs das VMs ⛔ só depois do ARM deploy = Succeeded

```powershell
# ⚠️ NIC names sem hífen — vêm do FirewallManager_parameters.json
$wl01Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name $SRV_WL01_NIC).IpConfigurations[0].PrivateIpAddress
$wl02Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name $SRV_WL02_NIC).IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-workload-01 IP: $wl01Ip"
Write-Host "Srv-workload-02 IP: $wl02Ip"
```

### Task 3 — Conectar Spokes ⛔ só depois do Hub = Succeeded

```powershell
$spoke01Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$spoke02Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02
New-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM -Name "hub-spoke-01" -RemoteVirtualNetwork $spoke01Vnet
New-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM -Name "hub-spoke-02" -RemoteVirtualNetwork $spoke02Vnet

Get-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM | Select-Object Name, ProvisioningState
```

### Task 5 — Firewall Policy

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

**Tasks 6-7 — Portal obrigatório**: Firewall Manager → associar `Policy-01` ao Secured Hub → ativar Internet routing + Private traffic routing nas ligações dos spokes.

**Tasks 8-9 — Manual**: RDP para Srv-workload-01 → `www.microsoft.com` ✅ → `www.google.com` ❌ → `mstsc 10.1.1.4` ✅

---

## ARM Templates — File Reference

| File | Purpose |
|------|---------|
| `ddos.json` | Cria VM `MyVirtualMachine` + NIC + NSG (allow RDP) na VNet `MyVirtualNetwork` subnet `default` |
| `ddos_parameters.json` | VM: `MyVirtualMachine`, NIC: `MyVirtualMachine-nic`, Size: `Standard_D2s_v3` |
| `firewall.json` | Cria VM `Srv-Work` + NIC na subnet `Workload-SN` da VNet `Test-FW-VN` (sem PIP, acesso via DNAT) |
| `firewall_parameters.json` | VM: `Srv-Work`, NIC: `Srv-Work-nic`, Size: `Standard_D2s_v3` |
| `FirewallManager.json` | Cria 2 VMs: `Srv-workload-01` (Spoke-01) e `Srv-workload-02` (Spoke-02) |
| `FirewallManager_parameters.json` | NICs: `Srv-workload-01nic` e `Srv-workload-02nic` (**sem hífen**) |

---

## ⚠️ Pontos críticos

- **Captura `$fwPrivateIp` e `$fwPublicIp` imediatamente** após criar o Firewall — são necessários para a DNAT rule e a route table
- **NIC names do FirewallManager ARM sem hífen** (`Srv-workload-01nic`) — usa `$SRV_WL01_NIC` / `$SRV_WL02_NIC` das variáveis
- **Hub do Firewall Manager leva ~30 min** — lança com `-AsJob` e deploy as VMs em paralelo
- **Tasks 6-7 do Part 9 são portal only** — não existe cmdlet PowerShell estável para associar policy a Secured Hub e configurar routing
- **ddos.json usa subnet `default`** — confirma que a VNet tem essa subnet, ou edita o ARM antes de deploy
