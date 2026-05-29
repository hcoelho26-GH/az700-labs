## AZ-700 M05 - Variables ##
 
# General
$RG              = "ContosoResourceGroup"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"
 
# Unit 4 - VNet & Subnets
$VNET_NAME      = "ContosoVNet"
$VNET_PREFIX    = "10.0.0.0/16"
$SUBNET_AG_NAME = "AGSubnet"
$SUBNET_AG      = "10.0.0.0/24"
$SUBNET_BE_NAME = "BackendSubnet"
$SUBNET_BE      = "10.0.1.0/24"
 
# Unit 4 - Application Gateway
$AG_NAME        = "ContosoAppGateway"
$AG_PIP_NAME    = "AGPublicIPAddress"
$AG_BE_POOL     = "BackendPool"
$AG_LISTENER    = "Listener"
$AG_RULE_NAME   = "RoutingRule"
$AG_HTTP_SETTING = "HTTPSetting"
 
# Unit 4 - Backend VMs
$VM1_NAME   = "BackendVM1"
$VM2_NAME   = "BackendVM2"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"
 
# Unit 6 - Web Apps
$APP_PLAN_EASTUS  = "ContosoAppPlan-EastUS"
$APP_PLAN_WESTEU  = "ContosoAppPlan-WestEU"
$WEBAPP1_NAME     = "ContosoWebApp1"
$WEBAPP2_NAME     = "ContosoWebApp2"
 
# Unit 6 - Front Door
$FD_NAME          = "ContosoFrontDoor"
$FD_ORIGIN_GROUP  = "default-origin-group"

## AZ-700 M05 - Resources ##
 
 
# Unit 4 - Task 1 - Create Application Gateway
 
New-AzResourceGroup -Name $RG -Location $LOCATION
 
# VNet with AGSubnet
$subnetAg = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_AG_NAME -AddressPrefix $SUBNET_AG
 
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $VNET_NAME `
  -AddressPrefix $VNET_PREFIX `
  -Subnet $subnetAg
 
# Public IP for Application Gateway
$agPip = New-AzPublicIpAddress `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $AG_PIP_NAME `
  -Sku Standard `
  -AllocationMethod Static
 
# Application Gateway IP config
$agSubnet   = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_AG_NAME
$agIpConfig = New-AzApplicationGatewayIPConfiguration -Name "agIPConfig" -Subnet $agSubnet
 
# Frontend IP
$feIpConfig = New-AzApplicationGatewayFrontendIPConfig -Name "feFrontendIp" -PublicIPAddress $agPip
 
# Frontend Port
$fePort = New-AzApplicationGatewayFrontendPort -Name "fePort" -Port 80
 
# Backend Pool (empty — VMs added in Task 3)
$bePool = New-AzApplicationGatewayBackendAddressPool -Name $AG_BE_POOL
 
# Backend HTTP Settings
$beHttpSettings = New-AzApplicationGatewayBackendHttpSetting `
  -Name $AG_HTTP_SETTING `
  -Port 80 `
  -Protocol Http `
  -CookieBasedAffinity Disabled `
  -RequestTimeout 20
 
# Listener
$listener = New-AzApplicationGatewayHttpListener `
  -Name $AG_LISTENER `
  -Protocol Http `
  -FrontendIPConfiguration $feIpConfig `
  -FrontendPort $fePort
 
# Routing Rule
$routingRule = New-AzApplicationGatewayRequestRoutingRule `
  -Name $AG_RULE_NAME `
  -RuleType Basic `
  -Priority 100 `
  -HttpListener $listener `
  -BackendAddressPool $bePool `
  -BackendHttpSettings $beHttpSettings
 
# SKU
$sku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2
 
# Create Application Gateway
New-AzApplicationGateway `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $AG_NAME `
  -GatewayIPConfigurations $agIpConfig `
  -FrontendIPConfigurations $feIpConfig `
  -FrontendPorts $fePort `
  -BackendAddressPools $bePool `
  -BackendHttpSettingsCollection $beHttpSettings `
  -HttpListeners $listener `
  -RequestRoutingRules $routingRule `
  -Sku $sku
 
Get-AzApplicationGateway -ResourceGroupName $RG -Name $AG_NAME | Select-Object Name, ProvisioningState, OperationalState
 
 
# Unit 4 - Task 1 - Add BackendSubnet to VNet
 
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
Add-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -VirtualNetwork $vnet -AddressPrefix $SUBNET_BE | Set-AzVirtualNetwork
 
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME) | Select-Object Name, AddressPrefix
 
 
# Unit 4 - Task 2 - Create Backend VMs with IIS
 
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
 
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id
 
foreach ($vmName in @($VM1_NAME, $VM2_NAME)) {
  $nic = New-AzNetworkInterface `
    -ResourceGroupName $RG -Location $LOCATION `
    -Name "$vmName-nic" -SubnetId $subnetId
 
  $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VM_SIZE |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $credential |
    Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
    Add-AzVMNetworkInterface -Id $nic.Id
 
  New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob
}
 
Write-Host "VMs being created in background. Waiting..."
Get-Job | Wait-Job
Get-AzVM -ResourceGroupName $RG | Select-Object Name, ProvisioningState
 
# Install IIS on both VMs
$iisScript = @"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Remove-Item C:\inetpub\wwwroot\iisstart.htm
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value `$(`$env:computername)
"@
 
foreach ($vmName in @($VM1_NAME, $VM2_NAME)) {
  Invoke-AzVMRunCommand `
    -ResourceGroupName $RG `
    -Name $vmName `
    -CommandId RunPowerShellScript `
    -ScriptString $iisScript
  Write-Host "IIS installed on $vmName"
}
 
 
# Unit 4 - Task 3 - Add Backend VMs to Backend Pool
 
$ag      = Get-AzApplicationGateway -ResourceGroupName $RG -Name $AG_NAME
$bePool  = Get-AzApplicationGatewayBackendAddressPool -ApplicationGateway $ag -Name $AG_BE_POOL
 
$nic1 = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$VM1_NAME-nic"
$nic2 = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$VM2_NAME-nic"
 
$nic1.IpConfigurations[0].ApplicationGatewayBackendAddressPools = $bePool
$nic2.IpConfigurations[0].ApplicationGatewayBackendAddressPools = $bePool
 
Set-AzNetworkInterface -NetworkInterface $nic1
Set-AzNetworkInterface -NetworkInterface $nic2
 
Write-Host "Backend VMs added to backend pool."
 
 
# Unit 4 - Task 4 - Manual (browser test)
# 1. Get the Application Gateway public IP:
#    (Get-AzPublicIpAddress -ResourceGroupName $RG -Name $AG_PIP_NAME).IpAddress
# 2. Open browser and navigate to that IP
# 3. Refresh — responses alternate between BackendVM1 and BackendVM2
 
 
# Unit 4 - Cleanup
# Remove-AzResourceGroup -Name $RG -Force -AsJob
 
 
# Unit 6 - Task 1 - Create two Web App instances
 
# App Service Plan + Web App - East US
New-AzAppServicePlan `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $APP_PLAN_EASTUS `
  -Tier Standard `
  -NumberofWorkers 1 `
  -WorkerSize Small
 
New-AzWebApp `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -AppServicePlan $APP_PLAN_EASTUS `
  -Name $WEBAPP1_NAME
 
# App Service Plan + Web App - West Europe
New-AzAppServicePlan `
  -ResourceGroupName $RG `
  -Location $LOCATION_WESTEU `
  -Name $APP_PLAN_WESTEU `
  -Tier Standard `
  -NumberofWorkers 1 `
  -WorkerSize Small
 
New-AzWebApp `
  -ResourceGroupName $RG `
  -Location $LOCATION_WESTEU `
  -AppServicePlan $APP_PLAN_WESTEU `
  -Name $WEBAPP2_NAME
 
Get-AzWebApp -ResourceGroupName $RG | Select-Object Name, Location, State
 
 
# Unit 6 - Task 2 - Create Azure Front Door
 
$app1 = Get-AzWebApp -ResourceGroupName $RG -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG -Name $WEBAPP2_NAME
 
$origin1 = New-AzFrontDoorOrigin `
  -Name "webapp1-origin" `
  -HostName $app1.DefaultHostName `
  -HttpPort 80 `
  -HttpsPort 443 `
  -Priority 1 `
  -Weight 1000
 
$origin2 = New-AzFrontDoorOrigin `
  -Name "webapp2-origin" `
  -HostName $app2.DefaultHostName `
  -HttpPort 80 `
  -HttpsPort 443 `
  -Priority 2 `
  -Weight 1000
 
$originGroup = New-AzFrontDoorOriginGroup `
  -Name $FD_ORIGIN_GROUP `
  -SessionAffinityState Disabled
 
$route = New-AzFrontDoorRoute `
  -Name "default-route" `
  -OriginGroup $originGroup `
  -PatternsToMatch "/*" `
  -SupportedProtocol Http,Https `
  -HttpsRedirect Enabled
 
New-AzFrontDoor `
  -ResourceGroupName $RG `
  -Name $FD_NAME `
  -SkuName Standard_AzureFrontDoor `
  -Origin @($origin1, $origin2) `
  -OriginGroup $originGroup `
  -Route $route
 
Get-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME | Select-Object Name, ProvisioningState
 
 
# Unit 6 - Task 3 - Manual (browser test)
# 1. Get the Front Door hostname:
#    (Get-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME).FrontendEndpoints[0].Hostname
# 2. Open browser and navigate to that hostname
# 3. Should connect to the nearest/lowest latency web app
# 4. Stop one web app and refresh — Front Door should failover automatically
 
 
# Unit 6 - Cleanup
# Remove-AzResourceGroup -Name $RG -Force -AsJob
 