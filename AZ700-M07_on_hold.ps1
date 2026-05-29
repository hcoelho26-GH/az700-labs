## AZ-700 M07 - Variables ##
 
# General
$LOCATION = "eastus"
 
# Unit 5 - Service Endpoints
$RG_SE           = "myResourceGroup"
$VNET_SE         = "CoreServicesVNet"
$VNET_SE_PFX     = "10.0.0.0/16"
$SUBNET_PVT      = "Private"
$SUBNET_PVT_PFX  = "10.0.0.0/24"
$SUBNET_PUB      = "Public"
$SUBNET_PUB_PFX  = "10.0.1.0/24"
$NSG_PVT         = "ContosoPrivateNSG"
$NSG_PUB         = "ContosoPublicNSG"
$STORAGE_ACCOUNT = "contosostorage$(-join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}))"
$FILE_SHARE      = "marketing"
$VM_PRIVATE      = "ContosoPrivate"
$VM_PUBLIC       = "ContosoPublic"
$VM_SIZE         = "Standard_DS2_v3"
$ADMIN_USER      = "TestUser"
 
# Unit 6 - Private Endpoint
$RG_PE           = "CreatePrivateEndpointQS-rg"
$VNET_PE         = "myVNet"
$VNET_PE_PFX     = "10.0.0.0/16"
$SUBNET_PE       = "myBackendSubnet"
$SUBNET_PE_PFX   = "10.0.0.0/24"
$SUBNET_BASTION  = "10.0.1.0/24"
$BASTION_NAME    = "myBastionHost"
$BASTION_PIP     = "myBastionIP"
$VM_PE           = "myVM"
$WEBAPP_PE       = "mywebapp$(-join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}))"
$APP_PLAN_PE     = "myAppServicePlan"
$PE_NAME         = "myPrivateEndpoint"
$PE_CONN         = "myConnection"
$DNS_ZONE_PE     = "privatelink.azurewebsites.net"
$DNS_LINK_PE     = "myDNSLink"


## AZ-700 M07 - Resources ##


# Unit 5 - Task 1 - Create VNet with Private and Public subnets

New-AzResourceGroup -Name $RG_SE -Location $LOCATION

$subnetPvt = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_PVT -AddressPrefix $SUBNET_PVT_PFX
$subnetPub = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_PUB -AddressPrefix $SUBNET_PUB_PFX

New-AzVirtualNetwork `
  -ResourceGroupName $RG_SE -Location $LOCATION `
  -Name $VNET_SE -AddressPrefix $VNET_SE_PFX `
  -Subnet $subnetPvt, $subnetPub

Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE) | Select-Object Name, AddressPrefix


# Unit 5 - Task 2 - Enable Service Endpoint on Private subnet

$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPvt = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT

Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $vnet `
  -Name $SUBNET_PVT `
  -AddressPrefix $SUBNET_PVT_PFX `
  -ServiceEndpoint "Microsoft.Storage" |
  Set-AzVirtualNetwork

Write-Host "Service endpoint Microsoft.Storage enabled on $SUBNET_PVT"


# Unit 5 - Task 3 - Create NSG and restrict outbound on Private subnet

# Private NSG — deny internet outbound, allow storage
$denyInternet = New-AzNetworkSecurityRuleConfig `
  -Name "Deny-Internet-Outbound" -Priority 110 `
  -Protocol * -Access Deny -Direction Outbound `
  -SourceAddressPrefix VirtualNetwork -SourcePortRange * `
  -DestinationAddressPrefix Internet -DestinationPortRange *

$allowStorage = New-AzNetworkSecurityRuleConfig `
  -Name "Allow-Storage-Outbound" -Priority 100 `
  -Protocol * -Access Allow -Direction Outbound `
  -SourceAddressPrefix VirtualNetwork -SourcePortRange * `
  -DestinationAddressPrefix Storage -DestinationPortRange *

$nsgPvt = New-AzNetworkSecurityGroup `
  -ResourceGroupName $RG_SE -Location $LOCATION `
  -Name $NSG_PVT -SecurityRules $allowStorage, $denyInternet

# Associate NSG to Private subnet
$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPvt = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT
$subnetPvt.NetworkSecurityGroup = $nsgPvt
Set-AzVirtualNetwork -VirtualNetwork $vnet

Write-Host "NSG associated to $SUBNET_PVT"


# Unit 5 - Task 4 - Add additional outbound rules (deny VNet outbound on Private)

$denyVnet = New-AzNetworkSecurityRuleConfig `
  -Name "Deny-VNet-Outbound" -Priority 120 `
  -Protocol * -Access Deny -Direction Outbound `
  -SourceAddressPrefix VirtualNetwork -SourcePortRange * `
  -DestinationAddressPrefix VirtualNetwork -DestinationPortRange *

$nsgPvt = Get-AzNetworkSecurityGroup -ResourceGroupName $RG_SE -Name $NSG_PVT
$nsgPvt | Add-AzNetworkSecurityRuleConfig `
  -Name "Deny-VNet-Outbound" -Priority 120 `
  -Protocol * -Access Deny -Direction Outbound `
  -SourceAddressPrefix VirtualNetwork -SourcePortRange * `
  -DestinationAddressPrefix VirtualNetwork -DestinationPortRange * |
  Set-AzNetworkSecurityGroup

Write-Host "Additional outbound deny rule added."


# Unit 5 - Task 5 - Allow RDP inbound on both NSGs

# Private NSG — allow RDP inbound
$nsgPvt = Get-AzNetworkSecurityGroup -ResourceGroupName $RG_SE -Name $NSG_PVT
$nsgPvt | Add-AzNetworkSecurityRuleConfig `
  -Name "Allow-RDP-Inbound" -Priority 100 `
  -Protocol Tcp -Access Allow -Direction Inbound `
  -SourceAddressPrefix * -SourcePortRange * `
  -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3389 |
  Set-AzNetworkSecurityGroup

# Public NSG — allow RDP inbound only
$nsgPub = New-AzNetworkSecurityGroup `
  -ResourceGroupName $RG_SE -Location $LOCATION `
  -Name $NSG_PUB

$nsgPub | Add-AzNetworkSecurityRuleConfig `
  -Name "Allow-RDP-Inbound" -Priority 100 `
  -Protocol Tcp -Access Allow -Direction Inbound `
  -SourceAddressPrefix * -SourcePortRange * `
  -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3389 |
  Set-AzNetworkSecurityGroup

# Associate Public NSG to Public subnet
$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPub = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PUB
$subnetPub.NetworkSecurityGroup = $nsgPub
Set-AzVirtualNetwork -VirtualNetwork $vnet

Write-Host "RDP rules configured on both NSGs."


# Unit 5 - Task 6 - Create Storage Account and restrict access to Private subnet

$storageAccount = New-AzStorageAccount `
  -ResourceGroupName $RG_SE `
  -Location $LOCATION `
  -Name $STORAGE_ACCOUNT `
  -SkuName Standard_LRS `
  -Kind StorageV2

# Add VNet rule — allow only Private subnet
$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPvt = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT

Add-AzStorageAccountNetworkRule `
  -ResourceGroupName $RG_SE `
  -Name $STORAGE_ACCOUNT `
  -VirtualNetworkResourceId $subnetPvt.Id

# Set default action to Deny (block all except VNet rule)
Update-AzStorageAccountNetworkRuleSet `
  -ResourceGroupName $RG_SE `
  -Name $STORAGE_ACCOUNT `
  -DefaultAction Deny

Write-Host "Storage account $STORAGE_ACCOUNT restricted to $SUBNET_PVT only."


# Unit 5 - Task 7 - Create file share in storage account

$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $RG_SE -Name $STORAGE_ACCOUNT)[0].Value
$storageCtx = New-AzStorageContext -StorageAccountName $STORAGE_ACCOUNT -StorageAccountKey $storageKey

New-AzStorageShare -Name $FILE_SHARE -Context $storageCtx

Write-Host "File share '$FILE_SHARE' created."


# Unit 5 - Task 8 - Restrict network access to subnet (already done in Task 6)
# Verify the network rules are set correctly
Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $RG_SE -Name $STORAGE_ACCOUNT


# Unit 5 - Task 9 - Create VMs (ContosoPrivate on Private, ContosoPublic on Public)

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE

# ContosoPrivate — Private subnet
$pvtSubnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT).Id
$pvtPip      = New-AzPublicIpAddress -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PRIVATE-pip" -Sku Standard -AllocationMethod Static
$pvtNic      = New-AzNetworkInterface -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PRIVATE-nic" -SubnetId $pvtSubnetId -PublicIpAddressId $pvtPip.Id -NetworkSecurityGroupId $nsgPvt.Id

$pvtVmConfig = New-AzVMConfig -VMName $VM_PRIVATE -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM_PRIVATE -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $pvtNic.Id

New-AzVM -ResourceGroupName $RG_SE -Location $LOCATION -VM $pvtVmConfig -AsJob

# ContosoPublic — Public subnet
$pubSubnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PUB).Id
$pubPip      = New-AzPublicIpAddress -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PUBLIC-pip" -Sku Standard -AllocationMethod Static
$pubNic      = New-AzNetworkInterface -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PUBLIC-nic" -SubnetId $pubSubnetId -PublicIpAddressId $pubPip.Id -NetworkSecurityGroupId $nsgPub.Id

$pubVmConfig = New-AzVMConfig -VMName $VM_PUBLIC -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM_PUBLIC -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $pubNic.Id

New-AzVM -ResourceGroupName $RG_SE -Location $LOCATION -VM $pubVmConfig -AsJob

Get-Job | Wait-Job
Get-AzVM -ResourceGroupName $RG_SE | Select-Object Name, ProvisioningState


# Unit 5 - Task 10 - Manual (confirm storage access via RDP)
# 1. RDP into ContosoPrivate
#    Run in PowerShell inside the VM:
#    $acctKey    = ConvertTo-SecureString -String "<storage-key>" -AsPlainText -Force
#    $credential = New-Object PSCredential "Azure\<storage-account-name>", $acctKey
#    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\<storage-account>.file.core.windows.net\marketing" -Credential $credential
#    Expected: drive Z maps successfully (Private subnet has service endpoint)
#
# 2. RDP into ContosoPublic and run the same script
#    Expected: Access is denied (Public subnet has no service endpoint)
#
# 3. Test internet from ContosoPrivate: Test-NetConnection -ComputerName www.bing.com -Port 80
#    Expected: fails (NSG blocks internet outbound from Private subnet)


# Unit 5 - Cleanup
# Remove-AzResourceGroup -Name $RG_SE -Force -AsJob


# Unit 6 - Task 1 - Create Resource Group and Web App

New-AzResourceGroup -Name $RG_PE -Location $LOCATION

New-AzAppServicePlan `
  -ResourceGroupName $RG_PE -Location $LOCATION `
  -Name $APP_PLAN_PE -Tier PremiumV2 -NumberofWorkers 1 -WorkerSize Small

New-AzWebApp `
  -ResourceGroupName $RG_PE -Location $LOCATION `
  -AppServicePlan $APP_PLAN_PE -Name $WEBAPP_PE

Get-AzWebApp -ResourceGroupName $RG_PE -Name $WEBAPP_PE | Select-Object Name, State, DefaultHostName


# Unit 6 - Task 2 - Create VNet and Bastion Host

$subnetPe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_PE -AddressPrefix $SUBNET_PE_PFX
$subnetBastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix $SUBNET_BASTION

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RG_PE -Location $LOCATION `
  -Name $VNET_PE -AddressPrefix $VNET_PE_PFX `
  -Subnet $subnetPe, $subnetBastion

$bastionPip = New-AzPublicIpAddress `
  -ResourceGroupName $RG_PE -Location $LOCATION `
  -Name $BASTION_PIP -Sku Standard -AllocationMethod Static

New-AzBastion `
  -ResourceGroupName $RG_PE `
  -Name $BASTION_NAME `
  -VirtualNetwork $vnet `
  -PublicIpAddress $bastionPip

Get-AzBastion -ResourceGroupName $RG_PE -Name $BASTION_NAME | Select-Object Name, ProvisioningState


# Unit 6 - Task 3 - Create Test VM

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_PE -Name $VNET_PE
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PE).Id

$nic = New-AzNetworkInterface `
  -ResourceGroupName $RG_PE -Location $LOCATION `
  -Name "$VM_PE-nic" -SubnetId $subnetId

$vmConfig = New-AzVMConfig -VMName $VM_PE -VMSize $VM_SIZE |
  Set-AzVMOperatingSystem -Windows -ComputerName $VM_PE -Credential $credential |
  Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest |
  Add-AzVMNetworkInterface -Id $nic.Id

New-AzVM -ResourceGroupName $RG_PE -Location $LOCATION -VM $vmConfig

Get-AzVM -ResourceGroupName $RG_PE -Name $VM_PE | Select-Object Name, ProvisioningState


# Unit 6 - Task 4 - Create Private Endpoint

$webapp = Get-AzWebApp -ResourceGroupName $RG_PE -Name $WEBAPP_PE

$peConn = New-AzPrivateLinkServiceConnection `
  -Name $PE_CONN `
  -PrivateLinkServiceId $webapp.Id `
  -GroupId "sites"

$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_PE -Name $VNET_PE
$subnetPe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PE

# Disable private endpoint network policies on subnet
$subnetPe.PrivateEndpointNetworkPolicies = "Disabled"
Set-AzVirtualNetwork -VirtualNetwork $vnet

$privateEndpoint = New-AzPrivateEndpoint `
  -ResourceGroupName $RG_PE -Location $LOCATION `
  -Name $PE_NAME `
  -Subnet $subnetPe `
  -PrivateLinkServiceConnection $peConn

Get-AzPrivateEndpoint -ResourceGroupName $RG_PE -Name $PE_NAME | Select-Object Name, ProvisioningState


# Unit 6 - Task 5 - Configure Private DNS Zone

$dnsZone = New-AzPrivateDnsZone `
  -ResourceGroupName $RG_PE `
  -Name $DNS_ZONE_PE

$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_PE -Name $VNET_PE

New-AzPrivateDnsVirtualNetworkLink `
  -ResourceGroupName $RG_PE `
  -ZoneName $DNS_ZONE_PE `
  -Name $DNS_LINK_PE `
  -VirtualNetworkId $vnet.Id

# Create DNS config for the private endpoint
$peNic    = Get-AzNetworkInterface -ResourceGroupName $RG_PE -Name "$PE_NAME.nic*" -ErrorAction SilentlyContinue
if (-not $peNic) {
  $peNic = (Get-AzPrivateEndpoint -ResourceGroupName $RG_PE -Name $PE_NAME).NetworkInterfaces[0]
}

$peIp = (Get-AzNetworkInterface -ResourceId $peNic.Id).IpConfigurations[0].PrivateIpAddress

New-AzPrivateDnsRecordSet `
  -ResourceGroupName $RG_PE `
  -ZoneName $DNS_ZONE_PE `
  -Name $WEBAPP_PE `
  -RecordType A -Ttl 10 `
  -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $peIp)

Write-Host "Private DNS zone configured. Web app private IP: $peIp"


# Unit 6 - Task 6 - Manual (test via Bastion)
# 1. Connect to myVM via Bastion in the portal
# 2. Inside myVM, open browser and navigate to: https://<webapp-name>.azurewebsites.net
#    Expected: web app loads successfully via private endpoint
# 3. Run: nslookup <webapp-name>.azurewebsites.net
#    Expected: resolves to private IP (10.0.0.x), not public IP


# Unit 6 - Cleanup
# Remove-AzResourceGroup -Name $RG_PE -Force -AsJob