# M04 — Load Balancer & Traffic Manager

## Variables

<details>
<summary>Show variables</summary>

```powershell
# Part 4 - Load Balancer
# LearnOnDemand: RG is created in Task 1 (not pre-created)
$RG              = "IntLB-RG"
$LOCATION        = "eastus"

$VNET_NAME      = "IntLB-VNet"         ; $VNET_PREFIX    = "10.1.0.0/16"
$SUBNET_BE_NAME = "myBackendSubnet"    ; $SUBNET_BE      = "10.1.0.0/24"
$SUBNET_FE_NAME = "myFrontEndSubnet"   ; $SUBNET_FE      = "10.1.2.0/24"
$BASTION_NAME   = "myBastionHost"
$BASTION_PIP    = "myBastionIP"
$BASTION_SUBNET = "10.1.1.0/26"

$VM1_NAME   = "myVM1" ; $VM2_NAME = "myVM2" ; $VM3_NAME = "myVM3"
$NSG_NAME   = "myNSG"
$AVSET_NAME = "myAvailabilitySet"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

$LB_NAME       = "myIntLoadBalancer"
$LB_FE_NAME    = "LoadBalancerFrontEnd"
$LB_BE_NAME    = "myBackendPool"
$LB_PROBE_NAME = "myHealthProbe"
$LB_RULE_NAME  = "myHTTPRule"

$TESTVM_NAME = "myTestVM"
$TESTVM_NIC  = "myTestVM-nic"

# Part 6 - Traffic Manager
# LearnOnDemand: use region capacity checker in lab guide to find available regions
# Session example: West US 2 and Canada Central
$RG_TM1       = "Contoso-RG-TM1"
$RG_TM2       = "Contoso-RG-TM2"
$LOCATION_TM1 = "westus2"        # Update based on capacity checker result
$LOCATION_TM2 = "canadacentral"  # Update based on capacity checker result

$WEBAPP1_NAME = "ContosoWebAppOne<LABID>"
$WEBAPP2_NAME = "ContosoWebAppTwo<LABID>"
$APP_PLAN1    = "ContosoAppServicePlanOne<LABID>"
$APP_PLAN2    = "ContosoAppServicePlanTwo<LABID>"

$TM_PROFILE  = "Contoso-TMProfile<LABID>"  # Must be globally unique — add LABID
$TM_EP1_NAME = "ContosoEastEndpoint"
$TM_EP2_NAME = "ContosoWestEndpoint"
```

</details>

---

## Part 4 — Load Balancer

### Task 1 — VNet + Bastion

> ⏱️ Bastion takes ~11 min to provision.  
> 💡 **Tip**: You can start Task 2 (ARM template deployment) immediately after launching Bastion — it does not depend on Bastion completing.

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION

$subnetBe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -AddressPrefix $SUBNET_BE
$subnetFe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FE_NAME -AddressPrefix $SUBNET_FE
$subnetBastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix $BASTION_SUBNET

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $VNET_NAME -AddressPrefix $VNET_PREFIX `
  -Subnet $subnetBe, $subnetFe, $subnetBastion

$bastionPip = New-AzPublicIpAddress `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $BASTION_PIP -Sku Standard -AllocationMethod Static

New-AzBastion `
  -ResourceGroupName $RG -Name $BASTION_NAME `
  -VirtualNetwork $vnet -PublicIpAddress $bastionPip -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

Get-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME) |
  Select-Object Name, AddressPrefix
```

</details>

---

### Task 2 — Backend VMs

> ⚠️ **LearnOnDemand**: VM creation via PowerShell is blocked. Use ARM template below.  
> ⏱️ ~8 min for 3 VMs via ARM template.  
> 💡 **Tip**: You can start Tasks 3-4 (Load Balancer + Rules) while VMs are provisioning. Only add VMs to Backend Pool after they complete.

The ARM template creates myVM1, myVM2 and myVM3 and installs IIS automatically via `install-iis.ps1`.

> ⚠️ NIC names created by ARM template are `myVMnic1`, `myVMnic2`, `myVMnic3` — not `myVM1-nic`. Use these when adding to Backend Pool.

<details>
<summary>ARM Template — LearnOnDemand (recommended)</summary>

Upload `azuredeploy.json` and `azuredeploy.parameters.json` to Cloud Shell:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG `
  -Name "deploy-backend-vms" `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json `
  -adminPassword (Read-Host "VM Password" -AsSecureString) `
  -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check deployment status
Get-AzResourceGroupDeployment -ResourceGroupName $RG | Select-Object DeploymentName, ProvisioningState
```

</details>

<details>
<summary>PowerShell — unrestricted environments</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id

$nsgRule = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION -Name $NSG_NAME -SecurityRules $nsgRule
$avSet   = New-AzAvailabilitySet -ResourceGroupName $RG -Location $LOCATION -Name $AVSET_NAME -Sku Aligned -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5

foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION -Name "$vmName-nic" -SubnetId $subnetId -NetworkSecurityGroupId $nsg.Id
  $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VM_SIZE -AvailabilitySetId $avSet.Id |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $credential |
    Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
    Add-AzVMNetworkInterface -Id $nic.Id
  New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob
}

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

$iisScript = @"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Remove-Item C:\inetpub\wwwroot\iisstart.htm
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value `$(`$env:computername)
"@
foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  Invoke-AzVMRunCommand -ResourceGroupName $RG -Name $vmName -CommandId RunPowerShellScript -ScriptString $iisScript
}
```

</details>

---

### Tasks 3-4 — Load Balancer + Rules

> 💡 **Tip**: Run this while VMs are provisioning. Only the Backend Pool association requires VMs to exist.

<details>
<summary>Show code</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetFe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FE_NAME
$feConfig = New-AzLoadBalancerFrontendIpConfig -Name $LB_FE_NAME -SubnetId $subnetFe.Id

$lb = New-AzLoadBalancer `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $LB_NAME -Sku Standard `
  -FrontendIpConfiguration $feConfig

# Backend Pool
$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerBackendAddressPoolConfig -Name $LB_BE_NAME | Set-AzLoadBalancer

# Add VMs to Backend Pool
# LearnOnDemand: NIC names are myVMnic1, myVMnic2, myVMnic3 (ARM template naming)
# Unrestricted: NIC names are myVM1-nic, myVM2-nic, myVM3-nic
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME

foreach ($i in 1..3) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "myVMnic$i"  # ARM template naming
  # $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "myVM$i-nic"  # PowerShell naming
  $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $bePool
  Set-AzNetworkInterface -NetworkInterface $nic
}

# Health Probe
$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerProbeConfig `
  -Name $LB_PROBE_NAME -Protocol Http -Port 80 `
  -RequestPath "/" -IntervalInSeconds 15 -ProbeCount 2 |
  Set-AzLoadBalancer

# LB Rule
# Note: -EnableFloatingIP parameter not supported in all versions — omit it (default is $false)
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$feIp   = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $lb -Name $LB_FE_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
$probe  = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name $LB_PROBE_NAME

$lb | Add-AzLoadBalancerRuleConfig -Name $LB_RULE_NAME -FrontendIpConfiguration $feIp -BackendAddressPool $bePool -Probe $probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 | Set-AzLoadBalancer

Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object Name, ProvisioningState
```

</details>

---

### Task 4 — Test VM

> ⚠️ **LearnOnDemand**: VM creation via PowerShell is blocked. Create via portal.  
> Image: **Windows Server 2025 Datacenter Server Core - x64 Gen 2**  
> Networking: VNet `IntLB-VNet`, Subnet `myBackendSubnet`, Public IP `None`, NSG `myNSG`, Load balancing `None`

<details>
<summary>PowerShell — unrestricted environments</summary>

```powershell
$adminPassword = Read-Host "TestVM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id

$nic = New-AzNetworkInterface `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name "myTestVM-nic" -SubnetId $subnetId `
  -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzVMConfig -VMName $TESTVM_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $TESTVM_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2025-datacenter-core-g2 -Version latest |
  Add-AzVMNetworkInterface -Id $nic.Id

New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
```

</details>

---

### Task 5 — Test LB

> ⚠️ **Server Core**: no browser available. Test via PowerShell inside myTestVM via Bastion.  
> Connect to myTestVM via Bastion → select option **15 (Exit to PowerShell)** → run:

```powershell
Invoke-WebRequest -Uri "http://<LB_PRIVATE_IP>" -UseBasicParsing | Select-Object -ExpandProperty Content
```

> Expected: `myVM1`, `myVM2` or `myVM3`. `StatusCode: 200` confirms LB is working.  
> Note: Session persistence may always return the same VM when connecting from the same IP — this is normal behaviour.

```powershell
# Get LB Private IP from Cloud Shell
(Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME).FrontendIpConfigurations[0].PrivateIpAddress
```

---

## Part 6 — Traffic Manager

### Tasks 1 — Create Web Apps

> ⚠️ **LearnOnDemand**: App Service Plans and Web Apps are blocked via PowerShell — create via portal only.  
> ⚠️ Use the **region capacity checker** in the lab guide to find two available regions before creating. East US and West Europe may not have capacity.  
> ⚠️ On the Basics tab, uncheck **"Try a secure unique default hostname"** to avoid policy errors.  
> ⚠️ On the Monitor + secure tab, set **Application Insights** to **No**.

| Setting | Web App 1 | Web App 2 |
|---------|-----------|-----------|
| Resource Group | Contoso-RG-TM1 | Contoso-RG-TM2 |
| Name | ContosoWebAppOne`<LABID>` | ContosoWebAppTwo`<LABID>` |
| Runtime | ASP.NET V4.8 | ASP.NET V4.8 |
| OS | Windows | Windows |
| Region | From capacity checker | From capacity checker |
| Plan | ContosoAppServicePlanOne`<LABID>` | ContosoAppServicePlanTwo`<LABID>` |
| Pricing | Premium V3 P1V3 | Premium V3 P1V3 |

---

### Task 2 — Traffic Manager Profile

> ⚠️ `$TM_PROFILE` must be globally unique — add LABID to avoid DNS conflict.

<details>
<summary>Show code</summary>

```powershell
New-AzTrafficManagerProfile `
  -ResourceGroupName $RG_TM1 -Name $TM_PROFILE `
  -TrafficRoutingMethod Priority `
  -RelativeDnsName $TM_PROFILE `
  -Ttl 30 -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath "/"

Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM1 -Name $TM_PROFILE | Select-Object Name, TrafficRoutingMethod, ProfileStatus
```

</details>

---

### Task 3 — Traffic Manager Endpoints

<details>
<summary>Show code</summary>

```powershell
$app1 = Get-AzWebApp -ResourceGroupName $RG_TM1 -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG_TM2 -Name $WEBAPP2_NAME

New-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM1 -ProfileName $TM_PROFILE `
  -Name $TM_EP1_NAME -Type AzureEndpoints `
  -TargetResourceId $app1.Id -EndpointStatus Enabled -Priority 1

New-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM1 -ProfileName $TM_PROFILE `
  -Name $TM_EP2_NAME -Type AzureEndpoints `
  -TargetResourceId $app2.Id -EndpointStatus Enabled -Priority 2

# Verify endpoints
Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM1 -Name $TM_PROFILE |
  Select-Object -ExpandProperty Endpoints |
  Select-Object Name, EndpointStatus, EndpointMonitorStatus
```

</details>

---

### Task 4 — Test Traffic Manager

```powershell
# Get Traffic Manager DNS
(Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM1 -Name $TM_PROFILE).DnsConfig.Fqdn
```

Navigate to that DNS in browser — should show the primary Web App.

**Test failover** — disable primary endpoint:

```powershell
Disable-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM1 `
  -ProfileName $TM_PROFILE `
  -Name $TM_EP1_NAME `
  -Type AzureEndpoints -Force
```

> ⏱️ After disabling the primary endpoint, the secondary may show `Degraded` for **up to 20 minutes** — this is normal. Traffic Manager requires multiple consecutive successful health checks before promoting the endpoint.  
> The browser may already resolve to the secondary endpoint even while `Degraded` is shown — this is expected behaviour.

```powershell
# Monitor endpoint status
Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM1 -Name $TM_PROFILE |
  Select-Object -ExpandProperty Endpoints |
  Select-Object Name, EndpointStatus, EndpointMonitorStatus
```

---

## ARM Templates — File Reference

| File | Purpose |
|------|---------|
| `azuredeploy.json` | Creates VMs + NICs + NSG + installs IIS automatically |
| `azuredeploy.parameters.json` | Creates myVM1, myVM2, myVM3 (3 VMs, use `-vmCount 1` for single VM) |
| `install-iis.ps1` | Installs IIS and sets VM hostname as default page (called by ARM template) |
