# M08 — Monitor Load Balancer

## Variables

<details>
<summary>Show variables</summary>

```powershell
$RG       = "IntLB-RG"
$LOCATION = "eastus"

$VNET_NAME      = "myVNet"             ; $VNET_PREFIX    = "10.1.0.0/16"
$SUBNET_BE_NAME = "myBackendSubnet"    ; $SUBNET_BE      = "10.1.0.0/24"
$SUBNET_FE_NAME = "myFrontEndSubnet"   ; $SUBNET_FE      = "10.1.2.0/24"
$SUBNET_BH_NAME = "AzureBastionSubnet" ; $SUBNET_BH      = "10.1.1.0/26"
$BASTION_NAME   = "myBastionHost"
$BASTION_PIP    = "myBastionIP"

$LB_NAME       = "myIntLoadBalancer"
$LB_FE_NAME    = "LoadBalancerFrontEnd"
$LB_BE_NAME    = "myBackendPool"
$LB_PROBE_NAME = "myHealthProbe"
$LB_RULE_NAME  = "myHTTPRule"

$VM1_NAME   = "myVM1" ; $VM2_NAME = "myVM2" ; $VM3_NAME = "myVM3"
$NSG_NAME   = "myNSG"
$AVSET_NAME = "myAvailabilitySet"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

$LAW_NAME  = "myLAWorkspace"
$DIAG_NAME = "myLBDiagnostics"
```

</details>

---

## Task 1 — VNet + Bastion

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION
$subnetBe = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -AddressPrefix $SUBNET_BE
$subnetFe = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FE_NAME -AddressPrefix $SUBNET_FE
$subnetBh = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BH_NAME -AddressPrefix $SUBNET_BH
$vnet = New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION -Name $VNET_NAME -AddressPrefix $VNET_PREFIX -Subnet $subnetBe,$subnetFe,$subnetBh
$bastionPip = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION -Name $BASTION_PIP -Sku Standard -AllocationMethod Static
New-AzBastion -ResourceGroupName $RG -Name $BASTION_NAME -VirtualNetwork $vnet -PublicIpAddress $bastionPip
```

</details>

---

## Tasks 2-5 — Load Balancer + Rules

<details>
<summary>Show code</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetFe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FE_NAME
$feConfig = New-AzLoadBalancerFrontendIpConfig -Name $LB_FE_NAME -SubnetId $subnetFe.Id
$lb = New-AzLoadBalancer -ResourceGroupName $RG -Location $LOCATION -Name $LB_NAME -Sku Standard -FrontendIpConfiguration $feConfig

$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerBackendAddressPoolConfig -Name $LB_BE_NAME | Set-AzLoadBalancer

$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerProbeConfig -Name $LB_PROBE_NAME -Protocol Http -Port 80 -RequestPath "/" -IntervalInSeconds 15 -ProbeCount 2 | Set-AzLoadBalancer

$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$feIp   = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $lb -Name $LB_FE_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
$probe  = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name $LB_PROBE_NAME
$lb | Add-AzLoadBalancerRuleConfig -Name $LB_RULE_NAME -FrontendIpConfiguration $feIp -BackendAddressPool $bePool -Probe $probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -EnableFloatingIP $false | Set-AzLoadBalancer
```

</details>

---

## Tasks 6-7 — Backend VMs + IIS + Backend Pool

<details>
<summary>Show code</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id
$nsgRule  = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg      = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION -Name $NSG_NAME -SecurityRules $nsgRule
$avSet    = New-AzAvailabilitySet -ResourceGroupName $RG -Location $LOCATION -Name $AVSET_NAME -Sku Aligned -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5

foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION -Name "$vmName-nic" -SubnetId $subnetId -NetworkSecurityGroupId $nsg.Id
  $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VM_SIZE -AvailabilitySetId $avSet.Id | Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
  New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob
}
Get-Job | Wait-Job

$iisScript = @"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Remove-Item C:\inetpub\wwwroot\iisstart.htm
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value `$(`$env:computername)
"@
foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  Invoke-AzVMRunCommand -ResourceGroupName $RG -Name $vmName -CommandId RunPowerShellScript -ScriptString $iisScript
}

$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$vmName-nic"
  $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $bePool
  Set-AzNetworkInterface -NetworkInterface $nic
}
```

</details>

---

## Task 8 — Test LB

**Manual**: Connect to myVM1 via Bastion → open browser → navigate to LB Private IP → refresh to see responses alternate between VMs.

```powershell
(Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME).FrontendIpConfigurations[0].PrivateIpAddress
```

---

## Task 9 — Log Analytics Workspace

<details>
<summary>Show code</summary>

```powershell
$law = New-AzOperationalInsightsWorkspace -ResourceGroupName $RG -Location $LOCATION -Name $LAW_NAME -Sku PerGB2018
Get-AzOperationalInsightsWorkspace -ResourceGroupName $RG -Name $LAW_NAME | Select-Object Name, ProvisioningState, Sku
```

</details>

---

## Tasks 10-12 — Monitor Views

**Manual (portal only — no PowerShell equivalent)**:

- **Task 10 — Functional Dependency**: Monitor > Networks > Load Balancers > myIntLoadBalancer > Functional Dependency tab
- **Task 11 — Detailed Metrics**: Monitor > Networks > myIntLoadBalancer > Metrics — add `Data Path Availability`, `Health Probe Status`, `Byte Count`
- **Task 12 — Resource Health**: Monitor > Service Health > Resource Health > filter by Load Balancer

---

## Task 13 — Diagnostic Settings

<details>
<summary>Show code</summary>

```powershell
$lb  = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $RG -Name $LAW_NAME
Set-AzDiagnosticSetting -ResourceId $lb.Id -Name $DIAG_NAME -WorkspaceId $law.ResourceId -Enabled $true -MetricCategory "AllMetrics"
Get-AzDiagnosticSetting -ResourceId $lb.Id -Name $DIAG_NAME | Select-Object Name, WorkspaceId
```

</details>
