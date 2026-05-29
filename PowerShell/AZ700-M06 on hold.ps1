## AZ-700 M06 - Variables ##
 
# General
$LOCATION = "eastus"
 
# Unit 4 - DDoS
$RG_DDOS       = "MyResourceGroup"
$DDOS_PLAN     = "MyDdosProtectionPlan"
$VNET_DDOS     = "MyVirtualNetwork"
$VNET_DDOS_PFX = "10.1.0.0/16"
$SUBNET_DDOS   = "MySubnet"
$SUBNET_DDOS_PFX = "10.1.0.0/24"
$PIP_DDOS      = "MyPublicIPAddress"
$PIP_DNS       = "mypublicdns"
 
# Unit 7 - Firewall
$RG_FW         = "Test-FW-RG"
$VNET_FW       = "Test-FW-VN"
$VNET_FW_PFX   = "10.0.0.0/16"
$SUBNET_FW     = "AzureFirewallSubnet"
$SUBNET_FW_PFX = "10.0.1.0/26"
$SUBNET_WL     = "Workload-SN"
$SUBNET_WL_PFX = "10.0.2.0/24"
$FW_NAME       = "Test-FW01"
$FW_PIP        = "fw-pip"
$FW_POLICY     = "fw-test-pol"
$ROUTE_TABLE   = "Firewall-route"
$ROUTE_NAME    = "fw-dg"
$SRV_WORK      = "Srv-Work"
$ADMIN_USER    = "TestUser"
$VM_SIZE       = "Standard_DS2_v3"
 
# Unit 7 - Firewall rules
$APP_RULE_COLL  = "App-Coll01"
$NET_RULE_COLL  = "Net-Coll01"
$DNAT_RULE_COLL = "DNAT-Coll01"
 
# Unit 9 - Firewall Manager
$RG_FM         = "fw-manager-rg"
$VWAN_FM       = "Vwan-Hub"
$HUB_FM        = "Hub-01"
$HUB_FM_PFX    = "10.2.0.0/24"
$SPOKE01       = "Spoke-01"
$SPOKE01_PFX   = "10.0.0.0/16"
$SPOKE01_SUB   = "Workload-01-SN"
$SPOKE01_SPFX  = "10.0.1.0/24"
$SPOKE02       = "Spoke-02"
$SPOKE02_PFX   = "10.1.0.0/16"
$SPOKE02_SUB   = "Workload-02-SN"
$SPOKE02_SPFX  = "10.1.1.0/24"
$FW_POLICY_FM  = "Policy-01"
$SRV_WL01      = "Srv-workload-01"
$SRV_WL02      = "Srv-workload-02"


## AZ-700 M06 - Resources ##


# Unit 4 - Task 1 - Create Resource Group

New-AzResourceGroup -Name $RG_DDOS -Location $LOCATION


# Unit 4 - Task 2 - Create DDoS Protection Plan

$ddosPlan = New-AzDdosProtectionPlan `
  -ResourceGroupName $RG_DDOS `
  -Location $LOCATION `
  -Name $DDOS_PLAN

Get-AzDdosProtectionPlan -ResourceGroupName $RG_DDOS -Name $DDOS_PLAN | Select-Object Name, ProvisioningState


# Unit 4 - Task 3 - Create VNet with DDoS Protection enabled

$subnet = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_DDOS -AddressPrefix $SUBNET_DDOS_PFX

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG_DDOS `
  -Location $LOCATION `
  -Name $VNET_DDOS `
  -AddressPrefix $VNET_DDOS_PFX `
  -Subnet $subnet `
  -DdosProtectionPlan $ddosPlan `
  -EnableDdosProtection

Get-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Name $VNET_DDOS | Select-Object Name, EnableDdosProtection


# Unit 4 - Task 4 - Configure DDoS Telemetry (Public IP for metrics)

$pip = New-AzPublicIpAddress `
  -ResourceGroupName $RG_DDOS `
  -Location $LOCATION `
  -Name $PIP_DDOS `
  -Sku Standard `
  -AllocationMethod Static `
  -DomainNameLabel $PIP_DNS

Get-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Name $PIP_DDOS | Select-Object Name, IpAddress, DnsSettings


# Unit 4 - Tasks 5-6 - Manual (portal)
# Task 5: Configure diagnostic logs via portal:
#   DDoS Protection Plan > Monitoring > Diagnostic settings > Add
#   Enable: DDoSProtectionNotifications, DDoSMitigationFlowLogs, DDoSMitigationReports
# Task 6: Configure alerts via portal:
#   Public IP > Monitoring > Alerts > New alert rule
#   Metric: "Under DDoS attack or not"


# Unit 4 - Task 7 - Manual (simulation partner)
# Test with BreakingPoint Cloud or similar simulation partner
# BreakingPoint requires account creation at breakingpoint.cloud


# Unit 4 - Cleanup
# Remove-AzResourceGroup -Name $RG_DDOS -Force -AsJob


# Unit 7 - Task 1 - Create Resource Group

New-AzResourceGroup -Name $RG_FW -Location $LOCATION


# Unit 7 - Task 2 - Create VNet with Firewall and Workload subnets

$subnetFw = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FW -AddressPrefix $SUBNET_FW_PFX
$subnetWl = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_WL -AddressPrefix $SUBNET_WL_PFX

New-AzVirtualNetwork `
  -ResourceGroupName $RG_FW `
  -Location $LOCATION `
  -Name $VNET_FW `
  -AddressPrefix $VNET_FW_PFX `
  -Subnet $subnetFw, $subnetWl

Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW) | Select-Object Name, AddressPrefix


# Unit 7 - Task 3 - Create Workload VM (Srv-Work)

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL).Id

$nic = New-AzNetworkInterface `
  -ResourceGroupName $RG_FW -Location $LOCATION `
  -Name "$SRV_WORK-nic" -SubnetId $subnetId

$vmConfig = New-AzVMConfig -VMName $SRV_WORK -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WORK -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic.Id

New-AzVM -ResourceGroupName $RG_FW -Location $LOCATION -VM $vmConfig

$srvWorkIp = (Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name "$SRV_WORK-nic").IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-Work Private IP: $srvWorkIp"


# Unit 7 - Task 4 - Deploy Firewall and Firewall Policy

$fwPip = New-AzPublicIpAddress `
  -ResourceGroupName $RG_FW -Location $LOCATION `
  -Name $FW_PIP -Sku Standard -AllocationMethod Static

$fwPolicy = New-AzFirewallPolicy `
  -ResourceGroupName $RG_FW -Location $LOCATION `
  -Name $FW_POLICY

$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$fwSub = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FW

$fwIpConfig = New-AzFirewallIpConfiguration `
  -Name "fwIpConfig" `
  -PublicIPAddress $fwPip `
  -Subnet $fwSub

$firewall = New-AzFirewall `
  -ResourceGroupName $RG_FW -Location $LOCATION `
  -Name $FW_NAME `
  -Sku Standard `
  -FirewallPolicy $fwPolicy `
  -IpConfiguration $fwIpConfig

$fwPrivateIp = $firewall.IpConfigurations[0].PrivateIPAddress
Write-Host "Firewall Private IP: $fwPrivateIp"
Write-Host "Firewall Public IP:  $($fwPip.IpAddress)"


# Unit 7 - Task 5 - Create Default Route through Firewall

$routeTable = New-AzRouteTable `
  -ResourceGroupName $RG_FW -Location $LOCATION `
  -Name $ROUTE_TABLE `
  -DisableBgpRoutePropagation $false

$routeTable | Add-AzRouteConfig `
  -Name $ROUTE_NAME `
  -AddressPrefix "0.0.0.0/0" `
  -NextHopType VirtualAppliance `
  -NextHopIpAddress $fwPrivateIp |
  Set-AzRouteTable

# Associate route table to Workload-SN
$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subWl = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL
$subWl.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $vnet

Write-Host "Route table associated to $SUBNET_WL"


# Unit 7 - Task 6 - Configure Application Rule (allow www.google.com)

$appRule = New-AzFirewallPolicyApplicationRule `
  -Name "Allow-Google" `
  -SourceAddress "10.0.2.0/24" `
  -TargetFqdn "www.google.com" `
  -Protocol "http:80","https:443"

$appRuleCollection = New-AzFirewallPolicyFilterRuleCollection `
  -Name $APP_RULE_COLL `
  -Priority 200 `
  -ActionType Allow `
  -Rule $appRule

$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
$rcGroup  = New-AzFirewallPolicyRuleCollectionGroup `
  -Name "RuleCollectionGroup01" `
  -Priority 200 `
  -RuleCollection $appRuleCollection `
  -FirewallPolicyObject $fwPolicy

Write-Host "Application rule configured."


# Unit 7 - Task 7 - Configure Network Rule (allow DNS to 209.244.0.3 and 209.244.0.4)

$netRule = New-AzFirewallPolicyNetworkRule `
  -Name "Allow-DNS" `
  -SourceAddress "10.0.2.0/24" `
  -DestinationAddress "209.244.0.3","209.244.0.4" `
  -DestinationPort "53" `
  -Protocol UDP

$netRuleCollection = New-AzFirewallPolicyFilterRuleCollection `
  -Name $NET_RULE_COLL `
  -Priority 200 `
  -ActionType Allow `
  -Rule $netRule

$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
$rcGroup2 = New-AzFirewallPolicyRuleCollectionGroup `
  -Name "RuleCollectionGroup02" `
  -Priority 300 `
  -RuleCollection $netRuleCollection `
  -FirewallPolicyObject $fwPolicy

Write-Host "Network rule configured."


# Unit 7 - Task 8 - Configure DNAT Rule (RDP to Srv-Work via Firewall Public IP)

$dnatRule = New-AzFirewallPolicyNatRule `
  -Name "RDP-to-SrvWork" `
  -SourceAddress "*" `
  -DestinationAddress $fwPip.IpAddress `
  -DestinationPort "3389" `
  -Protocol TCP `
  -TranslatedAddress $srvWorkIp `
  -TranslatedPort "3389"

$dnatRuleCollection = New-AzFirewallPolicyNatRuleCollection `
  -Name $DNAT_RULE_COLL `
  -Priority 100 `
  -ActionType DNAT `
  -Rule $dnatRule

$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
$rcGroup3 = New-AzFirewallPolicyRuleCollectionGroup `
  -Name "RuleCollectionGroup03" `
  -Priority 100 `
  -RuleCollection $dnatRuleCollection `
  -FirewallPolicyObject $fwPolicy

Write-Host "DNAT rule configured."


# Unit 7 - Task 9 - Change DNS on Srv-Work NIC

$nic = Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name "$SRV_WORK-nic"
$nic.DnsSettings.DnsServers.Clear()
$nic.DnsSettings.DnsServers.Add("209.244.0.3")
$nic.DnsSettings.DnsServers.Add("209.244.0.4")
Set-AzNetworkInterface -NetworkInterface $nic

Write-Host "DNS updated on $SRV_WORK NIC."


# Unit 7 - Task 10 - Manual (test firewall via RDP)
# 1. RDP to Srv-Work using Firewall Public IP on port 3389:
#    mstsc /v:<FW_PUBLIC_IP>:3389  (user: TestUser)
# 2. Inside Srv-Work, open browser and test:
#    - www.google.com  → should WORK (allowed by app rule)
#    - www.microsoft.com → should be BLOCKED
# 3. Test DNS: nslookup www.google.com — should resolve via 209.244.0.3


# Unit 7 - Cleanup
# Remove-AzResourceGroup -Name $RG_FW -Force -AsJob


# Unit 9 - Task 1 - Create two Spoke VNets

New-AzResourceGroup -Name $RG_FM -Location $LOCATION

$sub01 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE01_SUB -AddressPrefix $SPOKE01_SPFX
New-AzVirtualNetwork `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name $SPOKE01 -AddressPrefix $SPOKE01_PFX -Subnet $sub01

$sub02 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE02_SUB -AddressPrefix $SPOKE02_SPFX
New-AzVirtualNetwork `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name $SPOKE02 -AddressPrefix $SPOKE02_PFX -Subnet $sub02

Get-AzVirtualNetwork -ResourceGroupName $RG_FM | Select-Object Name, Location, AddressSpace


# Unit 9 - Task 2 - Create Secured Virtual Hub (VWAN + Hub)
# NOTE: Hub takes up to 30 minutes to provision

$vwan = New-AzVirtualWan `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name $VWAN_FM -VirtualWANType Standard

New-AzVirtualHub `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name $HUB_FM `
  -VirtualWan $vwan `
  -AddressPrefix $HUB_FM_PFX `
  -Sku Standard

Get-AzVirtualHub -ResourceGroupName $RG_FM -Name $HUB_FM | Select-Object Name, ProvisioningState


# Unit 9 - Task 3 - Connect Hub and Spoke VNets
# Only run after Hub shows ProvisioningState = Succeeded

$hub   = Get-AzVirtualHub -ResourceGroupName $RG_FM -Name $HUB_FM
$spoke01Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$spoke02Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02

New-AzVirtualHubVnetConnection `
  -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM `
  -Name "hub-spoke-01" -RemoteVirtualNetwork $spoke01Vnet

New-AzVirtualHubVnetConnection `
  -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM `
  -Name "hub-spoke-02" -RemoteVirtualNetwork $spoke02Vnet

Get-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM | Select-Object Name, ProvisioningState


# Unit 9 - Task 4 - Deploy Workload Servers

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

# Srv-workload-01 in Spoke-01
$vnet01   = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$subnetId01 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet01 -Name $SPOKE01_SUB).Id

$nic01 = New-AzNetworkInterface `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name "$SRV_WL01-nic" -SubnetId $subnetId01

$vmConfig01 = New-AzVMConfig -VMName $SRV_WL01 -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WL01 -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic01.Id

New-AzVM -ResourceGroupName $RG_FM -Location $LOCATION -VM $vmConfig01 -AsJob

# Srv-workload-02 in Spoke-02
$vnet02   = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02
$subnetId02 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet02 -Name $SPOKE02_SUB).Id

$nic02 = New-AzNetworkInterface `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name "$SRV_WL02-nic" -SubnetId $subnetId02

$vmConfig02 = New-AzVMConfig -VMName $SRV_WL02 -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WL02 -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic02.Id

New-AzVM -ResourceGroupName $RG_FM -Location $LOCATION -VM $vmConfig02 -AsJob

Get-Job | Wait-Job
Get-AzVM -ResourceGroupName $RG_FM | Select-Object Name, ProvisioningState

$wl01Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name "$SRV_WL01-nic").IpConfigurations[0].PrivateIpAddress
$wl02Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name "$SRV_WL02-nic").IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-workload-01 Private IP: $wl01Ip"
Write-Host "Srv-workload-02 Private IP: $wl02Ip"


# Unit 9 - Task 5 - Create Firewall Policy

$fwPolicy = New-AzFirewallPolicy `
  -ResourceGroupName $RG_FM -Location $LOCATION `
  -Name $FW_POLICY_FM

# Application rule — allow www.microsoft.com
$appRule = New-AzFirewallPolicyApplicationRule `
  -Name "Allow-Microsoft" `
  -SourceAddress "10.0.1.0/24","10.1.1.0/24" `
  -TargetFqdn "www.microsoft.com" `
  -Protocol "http:80","https:443"

$appColl = New-AzFirewallPolicyFilterRuleCollection `
  -Name "App-Coll01" -Priority 200 -ActionType Allow -Rule $appRule

# Network rule — allow RDP to Srv-workload-01
$netRule1 = New-AzFirewallPolicyNetworkRule `
  -Name "Allow-RDP-Wl01" `
  -SourceAddress "*" `
  -DestinationAddress "10.0.1.4" `
  -DestinationPort "3389" -Protocol TCP

# Network rule — allow RDP to Srv-workload-02
$netRule2 = New-AzFirewallPolicyNetworkRule `
  -Name "Allow-RDP-Wl02" `
  -SourceAddress "*" `
  -DestinationAddress "10.1.1.4" `
  -DestinationPort "3389" -Protocol TCP

$netColl = New-AzFirewallPolicyFilterRuleCollection `
  -Name "Net-Coll01" -Priority 100 -ActionType Allow -Rule @($netRule1, $netRule2)

$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FM -Name $FW_POLICY_FM
New-AzFirewallPolicyRuleCollectionGroup `
  -Name "PolicyRuleGroup" -Priority 100 `
  -RuleCollection @($appColl, $netColl) `
  -FirewallPolicyObject $fwPolicy

Write-Host "Firewall policy and rules configured."


# Unit 9 - Task 6 - Associate Firewall Policy to Hub
# Done via portal: Firewall Manager > Secured virtual hubs > Hub-01 > Security configuration > Associate policy


# Unit 9 - Task 7 - Route Traffic to Hub
# Done via portal: Virtual Hub > Connections > hub-spoke-01 + hub-spoke-02 > Enable Internet traffic + Private traffic


# Unit 9 - Tasks 8-9 - Manual (test via RDP)
# Task 8 - Test application rule:
#   RDP into Srv-workload-01, open browser
#   www.microsoft.com → should WORK
#   www.google.com    → should be BLOCKED
#
# Task 9 - Test network rule:
#   Inside Srv-workload-01, open mstsc
#   Connect to Srv-workload-02 private IP (10.1.1.4)
#   Should connect successfully via RDP


# Unit 9 - Task 10 - Cleanup
# Remove-AzResourceGroup -Name $RG_FM -Force -AsJob