# M07 — Service Endpoints & Private Endpoint

## Variables

<details>
<summary>Show variables</summary>

```powershell
$LOCATION = "eastus"

$RG_SE           = "myResourceGroup"
$VNET_SE         = "CoreServicesVNet" ; $VNET_SE_PFX    = "10.0.0.0/16"
$SUBNET_PVT      = "Private"          ; $SUBNET_PVT_PFX = "10.0.0.0/24"
$SUBNET_PUB      = "Public"           ; $SUBNET_PUB_PFX = "10.0.1.0/24"
$NSG_PVT         = "ContosoPrivateNSG"
$NSG_PUB         = "ContosoPublicNSG"
$STORAGE_ACCOUNT = "contosostorage$(-join ((97..122) | Get-Random -Count 6 | ForEach-Object {[char]$_}))"
$FILE_SHARE      = "marketing"
$VM_PRIVATE      = "ContosoPrivate"
$VM_PUBLIC       = "ContosoPublic"
$VM_SIZE         = "Standard_DS2_v3"
$ADMIN_USER      = "TestUser"

$RG_PE          = "CreatePrivateEndpointQS-rg"
$VNET_PE        = "myVNet"             ; $VNET_PE_PFX    = "10.0.0.0/16"
$SUBNET_PE      = "myBackendSubnet"    ; $SUBNET_PE_PFX  = "10.0.0.0/24"
$SUBNET_BASTION = "10.0.1.0/24"
$BASTION_NAME   = "myBastionHost"
$BASTION_PIP    = "myBastionIP"
$VM_PE          = "myVM"
$WEBAPP_PE      = "mywebapp$(-join ((97..122) | Get-Random -Count 6 | ForEach-Object {[char]$_}))"
$APP_PLAN_PE    = "myAppServicePlan"
$PE_NAME        = "myPrivateEndpoint"
$PE_CONN        = "myConnection"
$DNS_ZONE_PE    = "privatelink.azurewebsites.net"
$DNS_LINK_PE    = "myDNSLink"
```

</details>

---

## Part 5 — Service Endpoints

<details>
<summary>Task 1 — VNet + Subnets</summary>

```powershell
New-AzResourceGroup -Name $RG_SE -Location $LOCATION
$subnetPvt = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_PVT -AddressPrefix $SUBNET_PVT_PFX
$subnetPub = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_PUB -AddressPrefix $SUBNET_PUB_PFX
New-AzVirtualNetwork -ResourceGroupName $RG_SE -Location $LOCATION -Name $VNET_SE -AddressPrefix $VNET_SE_PFX -Subnet $subnetPvt,$subnetPub
```

</details>

<details>
<summary>Task 2 — Enable Service Endpoint</summary>

```powershell
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT -AddressPrefix $SUBNET_PVT_PFX -ServiceEndpoint "Microsoft.Storage" | Set-AzVirtualNetwork
```

</details>

<details>
<summary>Tasks 3-5 — NSG Rules</summary>

```powershell
$allowStorage = New-AzNetworkSecurityRuleConfig -Name "Allow-Storage-Outbound" -Priority 100 -Protocol * -Access Allow -Direction Outbound -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix Storage -DestinationPortRange *
$denyInternet = New-AzNetworkSecurityRuleConfig -Name "Deny-Internet-Outbound" -Priority 110 -Protocol * -Access Deny -Direction Outbound -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix Internet -DestinationPortRange *
$nsgPvt = New-AzNetworkSecurityGroup -ResourceGroupName $RG_SE -Location $LOCATION -Name $NSG_PVT -SecurityRules $allowStorage,$denyInternet
$nsgPvt | Add-AzNetworkSecurityRuleConfig -Name "Deny-VNet-Outbound" -Priority 120 -Protocol * -Access Deny -Direction Outbound -SourceAddressPrefix VirtualNetwork -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange * | Set-AzNetworkSecurityGroup
$nsgPvt = Get-AzNetworkSecurityGroup -ResourceGroupName $RG_SE -Name $NSG_PVT
$nsgPvt | Add-AzNetworkSecurityRuleConfig -Name "Allow-RDP-Inbound" -Priority 100 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3389 | Set-AzNetworkSecurityGroup

$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPvt = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT
$subnetPvt.NetworkSecurityGroup = $nsgPvt
Set-AzVirtualNetwork -VirtualNetwork $vnet

$nsgPub = New-AzNetworkSecurityGroup -ResourceGroupName $RG_SE -Location $LOCATION -Name $NSG_PUB
$nsgPub | Add-AzNetworkSecurityRuleConfig -Name "Allow-RDP-Inbound" -Priority 100 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3389 | Set-AzNetworkSecurityGroup
$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPub = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PUB
$subnetPub.NetworkSecurityGroup = $nsgPub
Set-AzVirtualNetwork -VirtualNetwork $vnet
```

</details>

<details>
<summary>Tasks 6-8 — Storage Account + File Share</summary>

```powershell
$storageAccount = New-AzStorageAccount -ResourceGroupName $RG_SE -Location $LOCATION -Name $STORAGE_ACCOUNT -SkuName Standard_LRS -Kind FileStorage
$vnet      = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE
$subnetPvt = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT
Add-AzStorageAccountNetworkRule -ResourceGroupName $RG_SE -Name $STORAGE_ACCOUNT -VirtualNetworkResourceId $subnetPvt.Id
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $RG_SE -Name $STORAGE_ACCOUNT -DefaultAction Deny

$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $RG_SE -Name $STORAGE_ACCOUNT)[0].Value
$storageCtx = New-AzStorageContext -StorageAccountName $STORAGE_ACCOUNT -StorageAccountKey $storageKey
New-AzStorageShare -Name $FILE_SHARE -Context $storageCtx
```

</details>

<details>
<summary>Task 9 — Create VMs</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_SE -Name $VNET_SE

$pvtSubnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PVT).Id
$pvtPip  = New-AzPublicIpAddress -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PRIVATE-pip" -Sku Standard -AllocationMethod Static
$pvtNic  = New-AzNetworkInterface -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PRIVATE-nic" -SubnetId $pvtSubnetId -PublicIpAddressId $pvtPip.Id -NetworkSecurityGroupId $nsgPvt.Id
$pvtConfig = New-AzVMConfig -VMName $VM_PRIVATE -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM_PRIVATE -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $pvtNic.Id
New-AzVM -ResourceGroupName $RG_SE -Location $LOCATION -VM $pvtConfig -AsJob

$pubSubnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PUB).Id
$pubPip  = New-AzPublicIpAddress -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PUBLIC-pip" -Sku Standard -AllocationMethod Static
$pubNic  = New-AzNetworkInterface -ResourceGroupName $RG_SE -Location $LOCATION -Name "$VM_PUBLIC-nic" -SubnetId $pubSubnetId -PublicIpAddressId $pubPip.Id -NetworkSecurityGroupId $nsgPub.Id
$pubConfig = New-AzVMConfig -VMName $VM_PUBLIC -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM_PUBLIC -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $pubNic.Id
New-AzVM -ResourceGroupName $RG_SE -Location $LOCATION -VM $pubConfig -AsJob

Get-Job | Wait-Job
Get-AzVM -ResourceGroupName $RG_SE | Select-Object Name, ProvisioningState
```

</details>

**Task 10 — Manual**: RDP to ContosoPrivate → map Z: drive → expected: success. RDP to ContosoPublic → expected: `Access is denied`.

---

## Part 6 — Private Endpoint

<details>
<summary>Tasks 1-2 — Web App + VNet + Bastion</summary>

```powershell
New-AzResourceGroup -Name $RG_PE -Location $LOCATION
New-AzAppServicePlan -ResourceGroupName $RG_PE -Location $LOCATION -Name $APP_PLAN_PE -Tier PremiumV2 -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG_PE -Location $LOCATION -AppServicePlan $APP_PLAN_PE -Name $WEBAPP_PE

$subnetPe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_PE -AddressPrefix $SUBNET_PE_PFX
$subnetBastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix $SUBNET_BASTION
$vnet = New-AzVirtualNetwork -ResourceGroupName $RG_PE -Location $LOCATION -Name $VNET_PE -AddressPrefix $VNET_PE_PFX -Subnet $subnetPe,$subnetBastion
$bastionPip = New-AzPublicIpAddress -ResourceGroupName $RG_PE -Location $LOCATION -Name $BASTION_PIP -Sku Standard -AllocationMethod Static
New-AzBastion -ResourceGroupName $RG_PE -Name $BASTION_NAME -VirtualNetwork $vnet -PublicIpAddress $bastionPip
```

</details>

<details>
<summary>Task 3 — Test VM</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_PE -Name $VNET_PE
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PE).Id
$nic = New-AzNetworkInterface -ResourceGroupName $RG_PE -Location $LOCATION -Name "$VM_PE-nic" -SubnetId $subnetId
$vmConfig = New-AzVMConfig -VMName $VM_PE -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM_PE -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG_PE -Location $LOCATION -VM $vmConfig
```

</details>

<details>
<summary>Task 4 — Private Endpoint</summary>

```powershell
$webapp = Get-AzWebApp -ResourceGroupName $RG_PE -Name $WEBAPP_PE
$peConn = New-AzPrivateLinkServiceConnection -Name $PE_CONN -PrivateLinkServiceId $webapp.Id -GroupId "sites"
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_PE -Name $VNET_PE
$subnetPe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_PE
$subnetPe.PrivateEndpointNetworkPolicies = "Disabled"
Set-AzVirtualNetwork -VirtualNetwork $vnet
New-AzPrivateEndpoint -ResourceGroupName $RG_PE -Location $LOCATION -Name $PE_NAME -Subnet $subnetPe -PrivateLinkServiceConnection $peConn
Get-AzPrivateEndpoint -ResourceGroupName $RG_PE -Name $PE_NAME | Select-Object Name, ProvisioningState
```

</details>

<details>
<summary>Task 5 — Private DNS Zone</summary>

```powershell
New-AzPrivateDnsZone -ResourceGroupName $RG_PE -Name $DNS_ZONE_PE
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_PE -Name $VNET_PE
New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG_PE -ZoneName $DNS_ZONE_PE -Name $DNS_LINK_PE -VirtualNetworkId $vnet.Id
$peNic = (Get-AzPrivateEndpoint -ResourceGroupName $RG_PE -Name $PE_NAME).NetworkInterfaces[0]
$peIp  = (Get-AzNetworkInterface -ResourceId $peNic.Id).IpConfigurations[0].PrivateIpAddress
New-AzPrivateDnsRecordSet -ResourceGroupName $RG_PE -ZoneName $DNS_ZONE_PE -Name $WEBAPP_PE -RecordType A -Ttl 10 -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address $peIp)
Write-Host "Private DNS configured. Web app private IP: $peIp"
```

</details>

**Task 6 — Manual**: Connect to myVM via Bastion → navigate to `https://<webapp>.azurewebsites.net` → `nslookup` should resolve to `10.0.0.x`.
