# M05 — Application Gateway & Front Door

## Variables

<details>
<summary>Show variables</summary>

```powershell
# LearnOnDemand: check if RG is pre-created before running New-AzResourceGroup
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
# LearnOnDemand: use region capacity checker — Standard S1 pricing plan
# Session example: Central US and West Europe
$LOCATION_FD1    = "centralus"
$LOCATION_FD2    = "westeurope"
$APP_PLAN_EASTUS = "myAppServicePlanOne<LABID>"
$APP_PLAN_WESTEU = "myAppServicePlanTwo<LABID>"
$WEBAPP1_NAME    = "WebAppContoso-1-<LABID>"
$WEBAPP2_NAME    = "WebAppContoso-2-<LABID>"
$FD_NAME         = "ContosoFrontDoor<INICIAIS>"  # Must be unique in subscription — add your initials
```

</details>

---

## Part 4 — Application Gateway

### Task 1 — Create Application Gateway

> ⚠️ **LearnOnDemand**: check if RG is pre-created before running `New-AzResourceGroup`.  
> ⏱️ Application Gateway takes ~9 min to provision.  
> 💡 **Tip**: You can start Task 2 (ARM template deployment) immediately after launching the App Gateway with `-AsJob` — VMs do not depend on it completing.  
> ⛔ Only add VMs to Backend Pool (Task 3) after App Gateway shows `Succeeded`.

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

# Add BackendSubnet after VNet is created
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
Add-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -VirtualNetwork $vnet -AddressPrefix $SUBNET_BE | Set-AzVirtualNetwork

# Check status periodically
Get-AzApplicationGateway -ResourceGroupName $RG -Name $AG_NAME | Select-Object Name, ProvisioningState, OperationalState
```

</details>

---

### Task 2 — Backend VMs + IIS

> ⚠️ **LearnOnDemand**: VM creation via PowerShell is blocked. Use ARM template below.  
> ⏱️ ~8-10 min for 2 VMs via ARM template.  
> ⚠️ IIS is **not** installed by the ARM template — run the IIS script manually after deployment completes.  
> ⚠️ Both VMs use the same `adminPassword` passed to the ARM template.  
> ⚠️ **BackendSubnet must exist before running this deployment** — it is created at the end of Task 1.  
> 💡 **Tip**: You can add VMs to the Backend Pool (Task 3) while IIS is installing.

<details>
<summary>ARM Template — LearnOnDemand (recommended)</summary>

Upload `backend.json` and `backend.parameters.json` to Cloud Shell:

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

After deployment completes, install IIS on both VMs via Cloud Shell:

```powershell
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

> ✅ **LearnOnDemand**: App Service Plans and Web Apps work via PowerShell in this lab.  
> ⚠️ Use the exact names from the lab including LABID — e.g. `WebAppContoso-1-<LABID>`.  
> ⚠️ Use the **region capacity checker** in the lab guide to find two available regions.  
> ⚠️ Pricing plan: **Standard S1**.

<details>
<summary>Show code</summary>

```powershell
New-AzAppServicePlan `
  -ResourceGroupName $RG -Location $LOCATION_FD1 `
  -Name $APP_PLAN_EASTUS -Tier Standard -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG -Location $LOCATION_FD1 `
  -AppServicePlan $APP_PLAN_EASTUS -Name $WEBAPP1_NAME

New-AzAppServicePlan `
  -ResourceGroupName $RG -Location $LOCATION_FD2 `
  -Name $APP_PLAN_WESTEU -Tier Standard -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG -Location $LOCATION_FD2 `
  -AppServicePlan $APP_PLAN_WESTEU -Name $WEBAPP2_NAME

Get-AzWebApp -ResourceGroupName $RG | Select-Object Name, Location, State
```

</details>

---

### Task 2 — Create Azure Front Door ⚠️ Portal only

> ⚠️ Use **Quick Create** via portal — it creates profile + endpoint + origin group + route in one step.  
> ⚠️ Creating via PowerShell (`New-AzFrontDoorCdn*`) leaves the endpoint without a route and without a working origin group — use portal.  
> ⚠️ `$FD_NAME` must be unique in the subscription — add your initials (e.g. `ContosoFrontDoorHVC`).

**Portal steps:**

1. Search for **Front Door and CDN profiles** → **Create**
2. Select **Quick create** → **Continue**
3. Fill in:

| Setting | Value |
|---------|-------|
| Resource group | ContosoResourceGroup |
| Name | ContosoFrontDoor`<INICIAIS>` |
| Tier | Standard |
| Endpoint Name | FDendpoint |
| Origin Type | App Service |
| Origin host name | `WebAppContoso-1-<LABID>` |

4. **Review + Create** → **Create**
5. After deployment → **Go to resource**
6. **Origin Groups** → select `default-origin-group`
7. **+ Add an origin** → App Service → `WebAppContoso-2-<LABID>` → **Add** → **Update**

> ⚠️ Health probe must use **HTTPS** — App Service redirects HTTP to HTTPS by default.  
> In Origin Groups → edit → Health probes → Protocol: **HTTPS** → **Update**

---

### Task 3 — Test Front Door ⚠️ Manual

> ⏱️ Front Door propagates in a few minutes after correct configuration.  
> ⚠️ Make sure you are using the correct endpoint hostname — the one created by Quick Create, not any endpoint created via PowerShell.

Get the endpoint hostname from the portal: Front Door resource → **Endpoints** → copy hostname.

**Test failover:**
1. Navigate to Front Door hostname in browser — confirm it loads
2. Portal → **App Services** → stop `WebAppContoso-1` → refresh browser — should still work via second app
3. Stop `WebAppContoso-2` → refresh browser — should now show an error

---

## ARM Templates — File Reference

| File | Purpose |
|------|---------|
| `backend.json` | Creates BackendVM1 + BackendVM2 with NICs on BackendSubnet |
| `backend.parameters.json` | Parameters — VM names, NIC names, size, admin username. Same password for both VMs. |
| `install-iis.ps1` | Installs IIS and sets VM hostname as default page — run manually via `Invoke-AzVMRunCommand` after deployment |
