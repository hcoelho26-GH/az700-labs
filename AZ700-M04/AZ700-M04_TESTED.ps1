## AZ-700 M04 - Variables ##
 
# General
$RG              = "IntLB-RG"
$RG_TM           = "Contoso-RG"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"
 
# Unit 4 - VNet
$VNET_NAME       = "IntLB-VNet"
$VNET_PREFIX     = "10.1.0.0/16"
$SUBNET_BE_NAME  = "myBackendSubnet"
$SUBNET_BE       = "10.1.0.0/24"
$SUBNET_FE_NAME  = "myFrontEndSubnet"
$SUBNET_FE       = "10.1.2.0/24"
$BASTION_NAME    = "myBastionHost"
$BASTION_PIP     = "myBastionIP"
$BASTION_SUBNET  = "10.1.1.0/26"
 
# Unit 4 - Backend VMs
$VM1_NAME   = "myVM1" ; $VM2_NAME = "myVM2" ; $VM3_NAME = "myVM3"
$NSG_NAME   = "myNSG"
$AVSET_NAME = "myAvailabilitySet"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"
 
# Unit 4 - Load Balancer
$LB_NAME       = "myIntLoadBalancer"
$LB_FE_NAME    = "LoadBalancerFrontEnd"
$LB_BE_NAME    = "myBackendPool"
$LB_PROBE_NAME = "myHealthProbe"
$LB_RULE_NAME  = "myHTTPRule"
 
# Unit 4 - Test VM
$TESTVM_NAME = "myTestVM"
$TESTVM_NIC  = "myTestVM-nic"
 
# Unit 6 - Web Apps
$APP_PLAN_NAME = "ContosoAppPlan"
$WEBAPP1_NAME  = "ContosoWebApp-EastUS"
$WEBAPP2_NAME  = "ContosoWebApp-WestEU"
 
# Unit 6 - Traffic Manager
$TM_PROFILE  = "Contoso-TMProfile"
$TM_EP1_NAME = "ContosoEastEndpoint"
$TM_EP2_NAME = "ContosoWestEndpoint"
 

## AZ-700 M04 - Resources ##
 
 
# Unit 4 - Task 1 - VNet + Subnets + Bastion
 
New-AzResourceGroup -Name $RG -Location $LOCATION
 
$subnetBe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -AddressPrefix $SUBNET_BE
$subnetFe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FE_NAME -AddressPrefix $SUBNET_FE
$subnetBastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix $BASTION_SUBNET
 
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $VNET_NAME `
  -AddressPrefix $VNET_PREFIX `
  -Subnet $subnetBe, $subnetFe, $subnetBastion
 
$bastionPip = New-AzPublicIpAddress `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $BASTION_PIP `
  -Sku Standard `
  -AllocationMethod Static
 
New-AzBastion `
  -ResourceGroupName $RG `
  -Name $BASTION_NAME `
  -VirtualNetwork $vnet `
  -PublicIpAddress $bastionPip
 
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME) | Select-Object Name, AddressPrefix
 
 
# Unit 4 - Task 2 - Create Backend VMs (myVM1, myVM2, myVM3)
 
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
  -ResourceGroupName $RG -Location $LOCATION -Name $NSG_NAME -SecurityRules $nsgRule
 
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
 
Write-Host "VMs being created in background. You can proceed to Task 3."
Get-Job | Wait-Job
Get-AzVM -ResourceGroupName $RG | Select-Object Name, ProvisioningState
 
 
# Unit 4 - Task 3 - Create Internal Load Balancer
 
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetFe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FE_NAME
 
$feConfig = New-AzLoadBalancerFrontendIpConfig `
  -Name $LB_FE_NAME `
  -SubnetId $subnetFe.Id
 
$lb = New-AzLoadBalancer `
  -ResourceGroupName $RG `
  -Location $LOCATION `
  -Name $LB_NAME `
  -Sku Standard `
  -FrontendIpConfiguration $feConfig
 
Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object Name, Location, ProvisioningState
 
 
# Unit 4 - Task 4 - Backend Pool + Health Probe + LB Rule
 
$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
 
# Backend Pool
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
  -Name $LB_PROBE_NAME -Protocol Http -Port 80 -RequestPath "/" -IntervalInSeconds 15 -ProbeCount 2 |
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
  -FrontendPort 80 `
  -BackendPort 80 `
  -IdleTimeoutInMinutes 15 `
  -EnableFloatingIP $false |
  Set-AzLoadBalancer
 
Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object Name, ProvisioningState
 
 
# Unit 4 - Task 4 - Create Test VM (no public IP, on BackendSubnet)
 
$nic = New-AzNetworkInterface `
  -ResourceGroupName $RG -Location $LOCATION `
  -Name $TESTVM_NIC -SubnetId $subnetId `
  -NetworkSecurityGroupId $nsg.Id
 
$vmConfig = New-AzVMConfig -VMName $TESTVM_NAME -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $TESTVM_NAME -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-Datacenter-Core -Version latest |
  Add-AzVMNetworkInterface -Id $nic.Id
 
New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig
 
Get-AzVM -ResourceGroupName $RG -Name $TESTVM_NAME | Select-Object Name, ProvisioningState
 
 
# Unit 4 - Task 5 - Manual (Bastion)
# 1. Get the Load Balancer Private IP:
#    Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object -ExpandProperty FrontendIpConfigurations
# 2. Connect to myTestVM via Bastion in the portal
# 3. Open browser on myTestVM and navigate to the LB Private IP
# 4. Refresh — responses come from different VMs (myVM1, myVM2, myVM3)
 
 
# Unit 4 - Cleanup
# Remove-AzResourceGroup -Name $RG -Force -AsJob
 
 
# Unit 6 - Task 1 - Create Web Apps in 2 regions
 
New-AzResourceGroup -Name $RG_TM -Location $LOCATION
 
# App Service Plan - East US
New-AzAppServicePlan `
  -ResourceGroupName $RG_TM `
  -Location $LOCATION `
  -Name "$APP_PLAN_NAME-EastUS" `
  -Tier Standard `
  -NumberofWorkers 1 `
  -WorkerSize Small
 
New-AzWebApp `
  -ResourceGroupName $RG_TM `
  -Location $LOCATION `
  -AppServicePlan "$APP_PLAN_NAME-EastUS" `
  -Name $WEBAPP1_NAME
 
# App Service Plan - West Europe
New-AzAppServicePlan `
  -ResourceGroupName $RG_TM `
  -Location $LOCATION_WESTEU `
  -Name "$APP_PLAN_NAME-WestEU" `
  -Tier Standard `
  -NumberofWorkers 1 `
  -WorkerSize Small
 
New-AzWebApp `
  -ResourceGroupName $RG_TM `
  -Location $LOCATION_WESTEU `
  -AppServicePlan "$APP_PLAN_NAME-WestEU" `
  -Name $WEBAPP2_NAME
 
Get-AzWebApp -ResourceGroupName $RG_TM | Select-Object Name, Location, State
 
 
# Unit 6 - Task 2 - Create Traffic Manager Profile
 
New-AzTrafficManagerProfile `
  -ResourceGroupName $RG_TM `
  -Name $TM_PROFILE `
  -TrafficRoutingMethod Priority `
  -RelativeDnsName $TM_PROFILE `
  -Ttl 30 `
  -MonitorProtocol HTTP `
  -MonitorPort 80 `
  -MonitorPath "/"
 
Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE | Select-Object Name, TrafficRoutingMethod, ProfileStatus
 
 
# Unit 6 - Task 3 - Add Traffic Manager Endpoints
 
$app1 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP2_NAME
 
# East US - Primary (Priority 1)
New-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM `
  -ProfileName $TM_PROFILE `
  -Name $TM_EP1_NAME `
  -Type AzureEndpoints `
  -TargetResourceId $app1.Id `
  -EndpointStatus Enabled `
  -Priority 1
 
# West Europe - Failover (Priority 2)
New-AzTrafficManagerEndpoint `
  -ResourceGroupName $RG_TM `
  -ProfileName $TM_PROFILE `
  -Name $TM_EP2_NAME `
  -Type AzureEndpoints `
  -TargetResourceId $app2.Id `
  -EndpointStatus Enabled `
  -Priority 2
 
Get-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Type AzureEndpoints | Select-Object Name, EndpointStatus, Priority
 
 
# Unit 6 - Task 4 - Manual (Test Traffic Manager)
# 1. Get the Traffic Manager DNS:
#    (Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE).DnsConfig.Fqdn
# 2. Open browser and navigate to the DNS — should resolve to East US
# 3. Disable the East US endpoint and test again — should failover to West Europe
 
 
# Unit 6 - Cleanup
# Remove-AzResourceGroup -Name $RG_TM -Force -AsJob