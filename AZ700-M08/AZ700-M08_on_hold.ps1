## AZ-700 M08 - Variables ##

# General
$RG       = "IntLB-RG"
$LOCATION = "eastus"

# VNet
$VNET_NAME      = "myVNet"
$VNET_PREFIX    = "10.1.0.0/16"
$SUBNET_BE_NAME = "myBackendSubnet"
$SUBNET_BE      = "10.1.0.0/24"
$SUBNET_FE_NAME = "myFrontEndSubnet"
$SUBNET_FE      = "10.1.2.0/24"
$SUBNET_BH_NAME = "AzureBastionSubnet"
$SUBNET_BH      = "10.1.1.0/26"
$BASTION_NAME   = "myBastionHost"
$BASTION_PIP    = "myBastionIP"

# Load Balancer
$LB_NAME        = "myIntLoadBalancer"
$LB_FE_NAME     = "LoadBalancerFrontEnd"
$LB_BE_NAME     = "myBackendPool"
$LB_PROBE_NAME  = "myHealthProbe"
$LB_RULE_NAME   = "myHTTPRule"

# Backend VMs
$VM1_NAME   = "myVM1"
$VM2_NAME   = "myVM2"
$VM3_NAME   = "myVM3"
$NSG_NAME   = "myNSG"
$AVSET_NAME = "myAvailabilitySet"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

# Log Analytics
$LAW_NAME   = "myLAWorkspace"
$DIAG_NAME  = "myLBDiagnostics"



## AZ-700 M08 - Resources ##


# Task 1 - Create VNet and subnets

New-AzResourceGroup -Name $RG -Location $LOCATION

$subnetBe = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -AddressPrefix $SUBNET_BE
$subnetFe = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FE_NAME -AddressPrefix $SUBNET_FE
$subnetBh = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BH_NAME -AddressPrefix $SUBNET_BH

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $VNET_NAME -AddressPrefix $VNET_PREFIX `
  -Subnet $subnetBe, $subnetFe, $subnetBh

$bastionPip = New-AzPublicIpAddress `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $BASTION_PIP -Sku Standard -AllocationMethod Static

New-AzBastion `
  -ResourceGroupName $RG -Name $BASTION_NAME `
  -VirtualNetwork $vnet -PublicIpAddress $bastionPip

Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME) | Select-Object Name, AddressPrefix


# Task 2 - Create Internal Load Balancer

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetFe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FE_NAME

$feConfig = New-AzLoadBalancerFrontendIpConfig `
  -Name $LB_FE_NAME -SubnetId $subnetFe.Id

$lb = New-AzLoadBalancer `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $LB_NAME -Sku Standard `
  -FrontendIpConfiguration $feConfig

Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object Name, Location, ProvisioningState


# Task 3 - Create Backend Pool

$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerBackendAddressPoolConfig -Name $LB_BE_NAME | Set-AzLoadBalancer

Get-AzLoadBalancerBackendAddressPool -LoadBalancer (Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME) -Name $LB_BE_NAME | Select-Object Name, ProvisioningState


# Task 4 - Create Health Probe

$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerProbeConfig `
  -Name $LB_PROBE_NAME -Protocol Http -Port 80 `
  -RequestPath "/" -IntervalInSeconds 15 -ProbeCount 2 |
  Set-AzLoadBalancer

Get-AzLoadBalancerProbeConfig -LoadBalancer (Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME) -Name $LB_PROBE_NAME | Select-Object Name, Protocol, Port


# Task 5 - Create Load Balancer Rule

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
  -FrontendPort 80 `
  -BackendPort 80 `
  -IdleTimeoutInMinutes 15 `
  -EnableFloatingIP $false |
  Set-AzLoadBalancer

Get-AzLoadBalancerRuleConfig -LoadBalancer (Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME) -Name $LB_RULE_NAME | Select-Object Name, Protocol, FrontendPort, BackendPort


# Task 6 - Create Backend VMs with IIS

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id

# NSG with RDP rule
$nsgRule = New-AzNetworkSecurityRuleConfig `
  -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow `
  -Direction Inbound -SourceAddressPrefix * -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $NSG_NAME -SecurityRules $nsgRule

# Availability Set
$avSet = New-AzAvailabilitySet `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $AVSET_NAME -Sku Aligned `
  -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5

# Create 3 VMs in parallel
foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = New-AzNetworkInterface `
    -ResourceGroupName $RG -Location $LOCATION `
    -Name "$vmName-nic" -SubnetId $subnetId `
    -NetworkSecurityGroupId $nsg.Id

  $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VM_SIZE -AvailabilitySetId $avSet.Id |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $credential |
    Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
    Add-AzVMNetworkInterface -Id $nic.Id

  New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob
}

Write-Host "VMs being created in background. Waiting..."
Get-Job | Wait-Job
Get-AzVM -ResourceGroupName $RG | Select-Object Name, ProvisioningState

# Install IIS on all 3 VMs
$iisScript = @"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Remove-Item C:\inetpub\wwwroot\iisstart.htm
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value `$(`$env:computername)
"@

foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  Invoke-AzVMRunCommand `
    -ResourceGroupName $RG -Name $vmName `
    -CommandId RunPowerShellScript `
    -ScriptString $iisScript
  Write-Host "IIS installed on $vmName"
}


# Task 7 - Add VMs to Backend Pool

$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME

foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$vmName-nic"
  $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $bePool
  Set-AzNetworkInterface -NetworkInterface $nic
}

Write-Host "All VMs added to backend pool."
Get-AzLoadBalancerBackendAddressPool -LoadBalancer (Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME) -Name $LB_BE_NAME | Select-Object Name, BackendIpConfigurations


# Task 8 - Manual (test load balancer via Bastion)
# 1. Get the LB Private IP:
#    (Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME).FrontendIpConfigurations[0].PrivateIpAddress
# 2. Connect to myVM1 via Bastion in the portal
# 3. Open browser inside myVM1 and navigate to the LB Private IP
# 4. Refresh several times — responses alternate between myVM1, myVM2, myVM3


# Task 9 - Create Log Analytics Workspace

$law = New-AzOperationalInsightsWorkspace `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $LAW_NAME -Sku PerGB2018

Get-AzOperationalInsightsWorkspace -ResourceGroupName $RG -Name $LAW_NAME | Select-Object Name, ProvisioningState, Sku


# Task 10 - Manual (Functional Dependency View)
# Portal: Monitor > Networks > Load Balancers > myIntLoadBalancer
# Select the "Functional Dependency" tab to view the interactive topology diagram
# Hover over LoadBalancerFrontEnd and myBackendPool to see connections


# Task 11 - Manual (Detailed Metrics)
# Portal: Monitor > Networks > Load Balancers > myIntLoadBalancer > Metrics
# Add metrics: Data Path Availability, Health Probe Status, Byte Count, Packet Count


# Task 12 - Manual (Resource Health)
# Portal: Monitor > Service Health > Resource Health
# Filter by Resource Type: Load Balancer
# Select myIntLoadBalancer to view health status


# Task 13 - Configure Diagnostic Settings

$lb  = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $RG -Name $LAW_NAME

Set-AzDiagnosticSetting `
  -ResourceId $lb.Id `
  -Name $DIAG_NAME `
  -WorkspaceId $law.ResourceId `
  -Enabled $true `
  -MetricCategory "AllMetrics"

Get-AzDiagnosticSetting -ResourceId $lb.Id -Name $DIAG_NAME | Select-Object Name, StorageAccountId, WorkspaceId


# Cleanup
# Remove-AzResourceGroup -Name $RG -Force -AsJob