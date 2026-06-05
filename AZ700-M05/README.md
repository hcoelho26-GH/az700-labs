# M05 — Application Gateway & Front Door

## Variables

<details>
<summary>Show variables</summary>

```powershell
# LearnOnDemand: RG may be pre-created — check before running New-AzResourceGroup
$RG              = "ContosoResourceGroup"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"

$VNET_NAME      = "ContosoVNet"    ; $VNET_PREFIX    = "10.0.0.0/16"
$SUBNET_AG_NAME = "AGSubnet"       ; $SUBNET_AG      = "10.0.0.0/24"
$SUBNET_BE_NAME = "BackendSubnet"  ; $SUBNET_BE      = "10.0.1.0/24"

$AG_NAME         = "ContosoAppGateway"
$AG_PIP_NAME     = "AGPublicIPAddress"
$AG_BE_POOL      = "BackendPool"
$AG_LISTENER     = "Listener"
$AG_RULE_NAME    = "RoutingRule"
$AG_HTTP_SETTING = "HTTPSetting"

$VM1_NAME   = "BackendVM1"
$VM2_NAME   = "BackendVM2"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

# Part 6 - Front Door
# LearnOnDemand: use region capacity checker — App Services may be blocked via PowerShell
$APP_PLAN_EASTUS = "ContosoAppPlan-EastUS"
$APP_PLAN_WESTEU = "ContosoAppPlan-WestEU"
$WEBAPP1_NAME    = "ContosoWebApp1<LABID>"
$WEBAPP2_NAME    = "ContosoWebApp2<LABID>"
$FD_NAME         = "ContosoFrontDoor<LABID>"  # Must be globally unique — add LABID
$FD_ORIGIN_GROUP = "default-origin-group"
```

</details>

---

## Part 4 — Application Gateway

### Task 1 — Create Application Gateway

> ⚠️ **LearnOnDemand**: check if RG is pre-created before running `New-AzResourceGroup`.  
> ⏱️ Application Gateway takes ~10-15 min to provision.  
> 💡 **Tip**: You can start Task 2 (ARM template deployment) immediately after launching the App Gateway — VMs do not depend on it completing.

<details>
<summary>Show code</summary>

```powershell
# Unrestricted only — skip if RG is pre-created
New-AzResourceGroup -Name $RG -Location $LOCATION

$subnetAg = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_AG_NAME -AddressPrefix $SUBNET_AG

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $VNET_NAME -AddressPrefix $VNET_PREFIX `
  -Subnet $subnetAg

$agPip      = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION -Name $AG_PIP_NAME -Sku Standard -AllocationMethod Static
$agSubnet   = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_AG_NAME
$agIpConfig = New-AzApplicationGatewayIPConfiguration -Name "agIPConfig" -Subnet $agSubnet
$feIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name "feFrontendIp" -PublicIPAddress $agPip
$fePort     = New-AzApplicationGatewayFrontendPort -Name "fePort" -Port 80
$bePool     = New-AzApplicationGatewayBackendAddressPool -Name $AG_BE_POOL
$beHttpSettings = New-AzApplicationGatewayBackendHttpSetting -Name $AG_HTTP_SETTING -Port 80 -Protocol Http -CookieBasedAffinity Disabled -RequestTimeout 20
$listener   = New-AzApplicationGatewayHttpListener -Name $AG_LISTENER -Protocol Http -FrontendIPConfiguration $feIpConfig -FrontendPort $fePort
$routingRule = New-AzApplicationGatewayRequestRoutingRule -Name $AG_RULE_NAME -RuleType Basic -Priority 100 -HttpListener $listener -BackendAddressPool $bePool -BackendHttpSettings $beHttpSettings
$sku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2

New-AzApplicationGateway `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $AG_NAME `
  -GatewayIPConfigurations $agIpConfig `
  -FrontendIPConfigurations $feIpConfig `
  -FrontendPorts $fePort `
  -BackendAddressPools $bePool `
  -BackendHttpSettingsCollection $beHttpSettings `
  -HttpListeners $listener `
  -RequestRoutingRules $routingRule `
  -Sku $sku -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check status periodically
Get-AzApplicationGateway -ResourceGroupName $RG -Name $AG_NAME | Select-Object Name, ProvisioningState, OperationalState

# Add BackendSubnet after VNet is created
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
Add-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -VirtualNetwork $vnet -AddressPrefix $SUBNET_BE | Set-AzVirtualNetwork
```

</details>

---

### Task 2 — Backend VMs + IIS

> ⚠️ **LearnOnDemand**: VM creation via PowerShell is blocked. Use ARM template below.  
> ⏱️ ~8-10 min for 2 VMs via ARM template.  
> ⚠️ IIS is **not** installed by the ARM template — run the IIS script manually after deployment.  
> 💡 **Tip**: You can add VMs to the Backend Pool (Task 3) while IIS is installing.

<details>
<summary>ARM Template — LearnOnDemand (recommended)</summary>

Upload `backend.json`, `backend.parameters.json` and `install-iis.ps1` to Cloud Shell:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $RG `
  -Name "deploy-backend-vms" `
  -TemplateFile backend.json `
  -TemplateParameterFile backend.parameters.json `
  -adminPassword (Read-Host "VM Password" -AsSecureString) `
  -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

# Check deployment status
Get-AzResourceGroupDeployment -ResourceGroupName $RG | Select-Object DeploymentName, ProvisioningState
```

After deployment completes, install IIS on both VMs:

```powershell
$iisScript = @"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Remove-Item C:\inetpub\wwwroot\iisstart.htm
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value `$(`$env:computername)
"@
foreach ($vmName in @($VM1_NAME, $VM2_NAME)) {
  Invoke-AzVMRunCommand -ResourceGroupName $RG -Name $vmName -CommandId RunPowerShellScript -ScriptString $iisScript
  Write-Host "IIS installed on $vmName"
}
```

</details>

<details>
<summary>PowerShell — unrestricted environments</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id

foreach ($vmName in @($VM1_NAME, $VM2_NAME)) {
  $nic = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION -Name "$vmName-nic" -SubnetId $subnetId
  $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VM_SIZE |
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
foreach ($vmName in @($VM1_NAME, $VM2_NAME)) {
  Invoke-AzVMRunCommand -ResourceGroupName $RG -Name $vmName -CommandId RunPowerShellScript -ScriptString $iisScript
}
```

</details>

---

### Task 3 — Add VMs to Backend Pool

> ⛔ Only run after App Gateway shows `ProvisioningState = Succeeded`.

<details>
<summary>Show code</summary>

```powershell
$ag     = Get-AzApplicationGateway -ResourceGroupName $RG -Name $AG_NAME
$bePool = Get-AzApplicationGatewayBackendAddressPool -ApplicationGateway $ag -Name $AG_BE_POOL

$nic1 = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$VM1_NAME-nic"
$nic2 = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$VM2_NAME-nic"

$nic1.IpConfigurations[0].ApplicationGatewayBackendAddressPools = $bePool
$nic2.IpConfigurations[0].ApplicationGatewayBackendAddressPools = $bePool

Set-AzNetworkInterface -NetworkInterface $nic1
Set-AzNetworkInterface -NetworkInterface $nic2

Write-Host "Backend VMs added to backend pool."
```

</details>

---

### Task 4 — Test App Gateway ⚠️ Manual

Navigate to App Gateway public IP → refresh to see responses from BackendVM1 and BackendVM2.

```powershell
(Get-AzPublicIpAddress -ResourceGroupName $RG -Name $AG_PIP_NAME).IpAddress
```

---

## Part 6 — Front Door

### Task 1 — Create Web Apps

> ⚠️ **LearnOnDemand**: App Service Plans and Web Apps may be blocked via PowerShell — create via portal if needed.  
> ⚠️ Use the **region capacity checker** in the lab guide to find two available regions.  
> ⚠️ On the Basics tab, uncheck **"Try a secure unique default hostname"** to avoid policy errors.  
> ⚠️ On the Monitor + secure tab, set **Application Insights** to **No**.

<details>
<summary>PowerShell — try first, use portal if blocked</summary>

```powershell
New-AzAppServicePlan `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $APP_PLAN_EASTUS -Tier Standard -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG -Location $LOCATION `
  -AppServicePlan $APP_PLAN_EASTUS -Name $WEBAPP1_NAME

New-AzAppServicePlan `
  -ResourceGroupName $RG -Location $LOCATION_WESTEU `
  -Name $APP_PLAN_WESTEU -Tier Standard -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG -Location $LOCATION_WESTEU `
  -AppServicePlan $APP_PLAN_WESTEU -Name $WEBAPP2_NAME

Get-AzWebApp -ResourceGroupName $RG | Select-Object Name, Location, State
```

</details>

---

### Task 2 — Create Azure Front Door

<details>
<summary>Show code</summary>

```powershell
$app1 = Get-AzWebApp -ResourceGroupName $RG -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG -Name $WEBAPP2_NAME

$origin1     = New-AzFrontDoorOrigin -Name "webapp1-origin" -HostName $app1.DefaultHostName -HttpPort 80 -HttpsPort 443 -Priority 1 -Weight 1000
$origin2     = New-AzFrontDoorOrigin -Name "webapp2-origin" -HostName $app2.DefaultHostName -HttpPort 80 -HttpsPort 443 -Priority 2 -Weight 1000
$originGroup = New-AzFrontDoorOriginGroup -Name $FD_ORIGIN_GROUP -SessionAffinityState Disabled
$route       = New-AzFrontDoorRoute -Name "default-route" -OriginGroup $originGroup -PatternsToMatch "/*" -SupportedProtocol Http,Https -HttpsRedirect Enabled

New-AzFrontDoor `
  -ResourceGroupName $RG -Name $FD_NAME `
  -SkuName Standard_AzureFrontDoor `
  -Origin @($origin1, $origin2) `
  -OriginGroup $originGroup `
  -Route $route -AsJob

Get-Job | Format-List Id, Name, State, PSBeginTime, PSEndTime

Get-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME | Select-Object Name, ProvisioningState
```

</details>

---

### Task 3 — Test Front Door ⚠️ Manual

Navigate to Front Door hostname → stop one web app to test failover.

```powershell
(Get-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME).FrontendEndpoints[0].Hostname
```

---

## ARM Templates — File Reference

| File | Purpose |
|------|---------|
| `backend.json` | Creates BackendVM1 + BackendVM2 with NICs on BackendSubnet |
| `backend.parameters.json` | Parameters — VM names, NIC names, size, admin username |
| `install-iis.ps1` | Installs IIS and sets VM hostname as default page — run manually after deployment |
