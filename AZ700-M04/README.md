# M04 — Load Balancer & Traffic Manager

## Variables

<details>
<summary>Show variables</summary>

```powershell
$RG              = "IntLB-RG"
$RG_TM           = "Contoso-RG"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"

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

$APP_PLAN_NAME = "ContosoAppPlan"
$WEBAPP1_NAME  = "ContosoWebApp-EastUS"
$WEBAPP2_NAME  = "ContosoWebApp-WestEU"

$TM_PROFILE  = "Contoso-TMProfile"
$TM_EP1_NAME = "ContosoEastEndpoint"
$TM_EP2_NAME = "ContosoWestEndpoint"
```

</details>

---

## Part 4 — Load Balancer

<details>
<summary>Task 1 — VNet + Bastion</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION
$subnetBe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -AddressPrefix $SUBNET_BE
$subnetFe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FE_NAME -AddressPrefix $SUBNET_FE
$subnetBastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix $BASTION_SUBNET
$vnet = New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION -Name $VNET_NAME -AddressPrefix $VNET_PREFIX -Subnet $subnetBe,$subnetFe,$subnetBastion
$bastionPip = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION -Name $BASTION_PIP -Sku Standard -AllocationMethod Static
New-AzBastion -ResourceGroupName $RG -Name $BASTION_NAME -VirtualNetwork $vnet -PublicIpAddress $bastionPip
```

</details>

<details>
<summary>Task 2 — Backend VMs</summary>

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
Get-AzVM -ResourceGroupName $RG | Select-Object Name, ProvisioningState
```

</details>

<details>
<summary>Tasks 3-4 — Load Balancer + Rules</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetFe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FE_NAME
$feConfig = New-AzLoadBalancerFrontendIpConfig -Name $LB_FE_NAME -SubnetId $subnetFe.Id
$lb = New-AzLoadBalancer -ResourceGroupName $RG -Location $LOCATION -Name $LB_NAME -Sku Standard -FrontendIpConfiguration $feConfig

$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerBackendAddressPoolConfig -Name $LB_BE_NAME | Set-AzLoadBalancer
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$vmName-nic"
  $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $bePool
  Set-AzNetworkInterface -NetworkInterface $nic
}

$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerProbeConfig -Name $LB_PROBE_NAME -Protocol Http -Port 80 -RequestPath "/" -IntervalInSeconds 15 -ProbeCount 2 | Set-AzLoadBalancer

$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$feIp   = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $lb -Name $LB_FE_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
$probe  = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name $LB_PROBE_NAME
$lb | Add-AzLoadBalancerRuleConfig -Name $LB_RULE_NAME -FrontendIpConfiguration $feIp -BackendAddressPool $bePool -Probe $probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -EnableFloatingIP $false | Set-AzLoadBalancer
```

</details>

<details>
<summary>Task 4 — Test VM</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id
$nic = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION -Name $TESTVM_NIC -SubnetId $subnetId -NetworkSecurityGroupId $nsg.Id
$vmConfig = New-AzVMConfig -VMName $TESTVM_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $TESTVM_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-Datacenter-Core -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig
```

</details>

**Task 5 — Manual**: Connect to myTestVM via Bastion → open browser → navigate to LB Private IP → refresh to see responses from different VMs.

```powershell
# Get LB Private IP
(Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME).FrontendIpConfigurations[0].PrivateIpAddress
```

---

## Part 6 — Traffic Manager

<details>
<summary>Tasks 1-3 — Web Apps + Profile + Endpoints</summary>

```powershell
New-AzResourceGroup -Name $RG_TM -Location $LOCATION
New-AzAppServicePlan -ResourceGroupName $RG_TM -Location $LOCATION -Name "$APP_PLAN_NAME-EastUS" -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG_TM -Location $LOCATION -AppServicePlan "$APP_PLAN_NAME-EastUS" -Name $WEBAPP1_NAME
New-AzAppServicePlan -ResourceGroupName $RG_TM -Location $LOCATION_WESTEU -Name "$APP_PLAN_NAME-WestEU" -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG_TM -Location $LOCATION_WESTEU -AppServicePlan "$APP_PLAN_NAME-WestEU" -Name $WEBAPP2_NAME

New-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE -TrafficRoutingMethod Priority -RelativeDnsName $TM_PROFILE -Ttl 30 -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath "/"

$app1 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP2_NAME
New-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Name $TM_EP1_NAME -Type AzureEndpoints -TargetResourceId $app1.Id -EndpointStatus Enabled -Priority 1
New-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Name $TM_EP2_NAME -Type AzureEndpoints -TargetResourceId $app2.Id -EndpointStatus Enabled -Priority 2
```

</details>

**Task 4 — Manual**: Navigate to Traffic Manager DNS → disable East US endpoint to test failover.

```powershell
# Get Traffic Manager DNS
(Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE).DnsConfig.Fqdn
```
