# M04 — Load Balancer & Traffic Manager

## Variables

<details>
<summary>Show variables</summary>

```powershell
# LearnOnDemand: RG is pre-created — update the suffix to match your lab number
$RG              = "IntLB-RG<LABID>"
$RG_TM           = "Contoso-RG"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"

# Part 4 - VNet
$VNET_NAME      = "IntLB-VNet"         ; $VNET_PREFIX    = "10.1.0.0/16"
$SUBNET_BE_NAME = "myBackendSubnet"    ; $SUBNET_BE      = "10.1.0.0/24"
$SUBNET_FE_NAME = "myFrontEndSubnet"   ; $SUBNET_FE      = "10.1.2.0/24"
$BASTION_NAME   = "myBastionHost"
$BASTION_PIP    = "myBastionIP"
$BASTION_SUBNET = "10.1.1.0/26"

# Part 4 - Backend VMs
$VM1_NAME   = "myVM1" ; $VM2_NAME = "myVM2" ; $VM3_NAME = "myVM3"
$NSG_NAME   = "myNSG"
$AVSET_NAME = "myAvailabilitySet"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

# Part 4 - Load Balancer
$LB_NAME       = "myIntLoadBalancer"
$LB_FE_NAME    = "LoadBalancerFrontEnd"
$LB_BE_NAME    = "myBackendPool"
$LB_PROBE_NAME = "myHealthProbe"
$LB_RULE_NAME  = "myHTTPRule"

# Part 4 - Test VM
$TESTVM_NAME = "myTestVM"
$TESTVM_NIC  = "myTestVM-nic"

# Part 6 - Web Apps
$APP_PLAN_NAME = "ContosoAppPlan"
$WEBAPP1_NAME  = "ContosoWebApp-EastUS"
$WEBAPP2_NAME  = "ContosoWebApp-WestEU"

# Part 6 - Traffic Manager
$TM_PROFILE  = "Contoso-TMProfile"
$TM_EP1_NAME = "ContosoEastEndpoint"
$TM_EP2_NAME = "ContosoWestEndpoint"
```

</details>

---

## Part 4 — Load Balancer

### Task 1 — VNet + Bastion

> ⚠️ **LearnOnDemand**: skip `New-AzResourceGroup` — RG is pre-created.

<details>
<summary>Show code</summary>

```powershell
# Unrestricted only
# New-AzResourceGroup -Name $RG -Location $LOCATION

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
  -VirtualNetwork $vnet -PublicIpAddress $bastionPip

Get-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME) |
  Select-Object Name, AddressPrefix
```

</details>

---

### Task 2 — Backend VMs

> ⚠️ **LearnOnDemand**: VM creation via PowerShell is blocked. Use ARM templates below.

<details>
<summary>ARM Template — LearnOnDemand (recommended)</summary>

Upload `azuredeploy.json` and `azuredeploy.parameters.json` to Cloud Shell.  
The template creates **myVM1, myVM2 and myVM3** in one deployment and installs IIS automatically via `install-iis.ps1`.

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

> Note: IIS is installed automatically by the ARM template via `install-iis.ps1` — no need to run it manually.

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

# Install IIS after VMs are provisioned
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
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME

foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$vmName-nic"
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
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$feIp   = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $lb -Name $LB_FE_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
$probe  = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name $LB_PROBE_NAME

$lb | Add-AzLoadBalancerRuleConfig `
  -Name $LB_RULE_NAME `
  -FrontendIpConfiguration $feIp `
  -BackendAddressPool $bePool `
  -Probe $probe `
  -Protocol Tcp `
  -FrontendPort 80 -BackendPort 80 `
  -IdleTimeoutInMinutes 15 `
  -EnableFloatingIP $false |
  Set-AzLoadBalancer

Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object Name, ProvisioningState
```

</details>

---

### Task 4 — Test VM

> ⚠️ **LearnOnDemand**: VM creation via PowerShell may be blocked. Use ARM template if needed.

<details>
<summary>ARM Template — LearnOnDemand</summary>

Upload `azuredeploy.json` and `azuredeploy.parameters.vm1.json` to Cloud Shell:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG `
  -Name "deploy-testvm" `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.vm1.json `
  -adminPassword (Read-Host "TestVM Password" -AsSecureString) `
  -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
```

</details>

<details>
<summary>PowerShell — unrestricted environments</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id

$nic = New-AzNetworkInterface `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $TESTVM_NIC -SubnetId $subnetId `
  -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzVMConfig -VMName $TESTVM_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $TESTVM_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-Datacenter-Core -Version latest |
  Add-AzVMNetworkInterface -Id $nic.Id

New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime
```

</details>

---

### Task 5 — Test LB ⚠️ Manual

Connect to `myTestVM` via Bastion → open browser → navigate to LB Private IP → refresh to see responses from different VMs.

```powershell
# Get LB Private IP
(Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME).FrontendIpConfigurations[0].PrivateIpAddress
```

---

## Part 6 — Traffic Manager

### Tasks 1-3 — Web Apps + Profile + Endpoints

<details>
<summary>Show code</summary>

```powershell
# Unrestricted only
# New-AzResourceGroup -Name $RG_TM -Location $LOCATION

New-AzAppServicePlan `
  -ResourceGroupName $RG_TM -Location $LOCATION `
  -Name "$APP_PLAN_NAME-EastUS" -Tier Standard -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG_TM -Location $LOCATION `
  -AppServicePlan "$APP_PLAN_NAME-EastUS" -Name $WEBAPP1_NAME

New-AzAppServicePlan `
  -ResourceGroupName $RG_TM -Location $LOCATION_WESTEU `
  -Name "$APP_PLAN_NAME-WestEU" -Tier Standard -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG_TM -Location $LOCATION_WESTEU `
  -AppServicePlan "$APP_PLAN_NAME-WestEU" -Name $WEBAPP2_NAME

Get-AzWebApp -ResourceGroupName $RG_TM | Select-Object Name, Location, State

New-AzTrafficManagerProfile `
  -ResourceGroupName $RG_TM -Name $TM_PROFILE `
  -TrafficRoutingMethod Priority `
  -RelativeDnsName $TM_PROFILE `
  -Ttl 30 -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath "/"

$app1 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP2_NAME

New-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE `
  -Name $TM_EP1_NAME -Type AzureEndpoints `
  -TargetResourceId $app1.Id -EndpointStatus Enabled -Priority 1

New-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE `
  -Name $TM_EP2_NAME -Type AzureEndpoints `
  -TargetResourceId $app2.Id -EndpointStatus Enabled -Priority 2

Get-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Type AzureEndpoints | Select-Object Name, EndpointStatus, Priority
```

</details>

---

### Task 4 — Test Traffic Manager ⚠️ Manual

Navigate to Traffic Manager DNS → disable East US endpoint to test failover to West Europe.

```powershell
# Get Traffic Manager DNS
(Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE).DnsConfig.Fqdn
```

## ARM Templates — File Reference

| File | Purpose |
|------|---------|
| `azuredeploy.json` | Creates VMs + NICs + NSG + installs IIS automatically |
| `azuredeploy.parameters.json` | Creates myVM1, myVM2, myVM3 (3 VMs in one deployment) |
| `azuredeploy.parameters.vm1.json` | Creates myVM1 only |
| `azuredeploy.parameters.vm2.json` | Creates myVM2 only |
| `azuredeploy.parameters.vm3.json` | Creates myVM3 only |
