# AZ-700 Lab Reference

> PowerShell reference for AZ-700 labs. Always run the **Variables** block first in each session.

---

## Table of Contents

### Variables
| Module | Contents |
|--------|----------|
| [M01 Variables](#m01-variables) | RG · VNets · DNS · VMs · Peerings |
| [M02 Variables](#m02-variables) | VNets · Gateways · Connections · VWAN |
| [M03 Variables](#m03-variables) | VNet · ER Gateway · ER Circuit |
| [M04 Variables](#m04-variables) | LB · VNet · Traffic Manager · Web Apps |
| [M05 Variables](#m05-variables) | App Gateway · Front Door · Web Apps |
| [M06 Variables](#m06-variables) | DDoS · Firewall · Firewall Manager |
| [M07 Variables](#m07-variables) | Service Endpoints · Private Endpoint |
| [M08 Variables](#m08-variables) | LB · VNet · Log Analytics |

### M01 — Virtual Networks, DNS & Peering
| Part | Tasks | Section |
|------|-------|---------|
| Part 4 | 1-4 | [Create VNets & Subnets](#m01-part-4--create-vnets--subnets) |
| Part 4 | 5 | [Verify VNets](#m01-part-4--verify-vnets) |
| Part 6 | 1 | [Private DNS Zone](#m01-part-6--private-dns-zone) |
| Part 6 | 2 | [VNet Link](#m01-part-6--vnet-link) |
| Part 6 | 3 | [testvm1 + testvm2](#m01-part-6--testvm1--testvm2) |
| Part 6 | 4 | [Verify DNS](#m01-part-6--verify-dns) |
| Part 8 | 1 | [ManufacturingVM](#m01-part-8--manufacturingvm) |
| Part 8 | 2-3 | [RDP + Tests ⚠️ manual](#m01-part-8--rdp--tests) |
| Part 8 | 4 | [VNet Peering](#m01-part-8--vnet-peering) |

### M02 — VPN Gateway & Virtual WAN
| Part | Tasks | Section |
|------|-------|---------|
| Part 3 | 1 | [Create VNets](#m02-part-3--create-vnets) |
| Part 3 | 2-3 | [CoreServicesVM + MfgVM](#m02-part-3--coreservicesvm--mfgvm) |
| Part 3 | 4-5 | [RDP + Tests ⚠️ manual](#m02-part-3--rdp--tests) |
| Part 3 | 6-7 | [VPN Gateways ⏱️ 45 min](#m02-part-3--vpn-gateways) |
| Part 3 | 8-9 | [VPN Connections](#m02-part-3--vpn-connections) |
| Part 7 | 1 | [Virtual WAN](#m02-part-7--virtual-wan) |
| Part 7 | 2 | [Virtual Hub ⏱️ 30 min](#m02-part-7--virtual-hub) |
| Part 7 | 3 | [Connect ResearchVnet](#m02-part-7--connect-researchvnet) |

### M03 — ExpressRoute
| Part | Tasks | Section |
|------|-------|---------|
| Part 4 | 1 | [VNet + GatewaySubnet](#m03-part-4--vnet--gatewaysubnet) |
| Part 4 | 2 | [ExpressRoute Gateway ⏱️ 45 min](#m03-part-4--expressroute-gateway) |
| Part 5 | 1 | [ExpressRoute Circuit ⚠️ billing](#m03-part-5--expressroute-circuit) |
| Part 5 | 2 | [Service Key](#m03-part-5--service-key) |
| Part 5 | 3 | [Deprovision ⛔ caution](#m03-part-5--deprovision) |

### M04 — Load Balancer & Traffic Manager
| Part | Tasks | Section |
|------|-------|---------|
| Part 4 | 1 | [VNet + Bastion](#m04-part-4--vnet--bastion) |
| Part 4 | 2 | [Backend VMs](#m04-part-4--backend-vms) |
| Part 4 | 3-4 | [Load Balancer + Rules](#m04-part-4--load-balancer--rules) |
| Part 4 | 5 | [Test VM](#m04-part-4--test-vm) |
| Part 4 | 6 | [Test LB ⚠️ manual](#m04-part-4--test-lb) |
| Part 6 | 1 | [Web Apps](#m04-part-6--web-apps) |
| Part 6 | 2 | [Traffic Manager Profile](#m04-part-6--traffic-manager-profile) |
| Part 6 | 3 | [Traffic Manager Endpoints](#m04-part-6--traffic-manager-endpoints) |
| Part 6 | 4 | [Test Traffic Manager ⚠️ manual](#m04-part-6--test-traffic-manager) |

### M05 — Application Gateway & Front Door
| Part | Tasks | Section |
|------|-------|---------|
| Part 4 | 1 | [Application Gateway](#m05-part-4--application-gateway) |
| Part 4 | 2 | [Backend VMs + IIS](#m05-part-4--backend-vms--iis) |
| Part 4 | 3 | [Add VMs to Backend Pool](#m05-part-4--add-vms-to-backend-pool) |
| Part 4 | 4 | [Test App Gateway ⚠️ manual](#m05-part-4--test-app-gateway) |
| Part 6 | 1 | [Web Apps](#m05-part-6--web-apps) |
| Part 6 | 2 | [Azure Front Door](#m05-part-6--azure-front-door) |
| Part 6 | 3 | [Test Front Door ⚠️ manual](#m05-part-6--test-front-door) |

### M06 — DDoS, Firewall & Firewall Manager
| Part | Tasks | Section |
|------|-------|---------|
| Part 4 | 1-3 | [DDoS Protection Plan + VNet](#m06-part-4--ddos-protection) |
| Part 4 | 4 | [DDoS Telemetry](#m06-part-4--ddos-telemetry) |
| Part 4 | 5-7 | [Diagnostics + Alerts + Sim ⚠️ manual](#m06-part-4--diagnostics--alerts) |
| Part 7 | 1-2 | [Firewall VNet + VM](#m06-part-7--firewall-vnet--vm) |
| Part 7 | 3-4 | [Deploy Firewall + Policy](#m06-part-7--deploy-firewall) |
| Part 7 | 5 | [Default Route](#m06-part-7--default-route) |
| Part 7 | 6-8 | [Firewall Rules](#m06-part-7--firewall-rules) |
| Part 7 | 9 | [Change DNS](#m06-part-7--change-dns) |
| Part 7 | 10 | [Test Firewall ⚠️ manual](#m06-part-7--test-firewall) |
| Part 9 | 1-2 | [Spoke VNets + Secured Hub](#m06-part-9--spoke-vnets--secured-hub) |
| Part 9 | 3 | [Connect Hub and Spokes](#m06-part-9--connect-hub-and-spokes) |
| Part 9 | 4 | [Deploy Workload Servers](#m06-part-9--deploy-workload-servers) |
| Part 9 | 5 | [Firewall Policy](#m06-part-9--firewall-policy) |
| Part 9 | 6-9 | [Associate + Route + Test ⚠️ partial manual](#m06-part-9--associate--route--test) |

### M07 — Service Endpoints & Private Endpoint
| Part | Tasks | Section |
|------|-------|---------|
| Part 5 | 1 | [VNet + Subnets](#m07-part-5--vnet--subnets) |
| Part 5 | 2 | [Enable Service Endpoint](#m07-part-5--enable-service-endpoint) |
| Part 5 | 3-5 | [NSG Rules](#m07-part-5--nsg-rules) |
| Part 5 | 6-8 | [Storage Account](#m07-part-5--storage-account) |
| Part 5 | 9 | [Create VMs](#m07-part-5--create-vms) |
| Part 5 | 10 | [Test Storage Access ⚠️ manual](#m07-part-5--test-storage-access) |
| Part 6 | 1 | [Web App](#m07-part-6--web-app) |
| Part 6 | 2 | [VNet + Bastion](#m07-part-6--vnet--bastion) |
| Part 6 | 3 | [Test VM](#m07-part-6--test-vm) |
| Part 6 | 4 | [Private Endpoint](#m07-part-6--private-endpoint) |
| Part 6 | 5 | [Private DNS Zone](#m07-part-6--private-dns-zone) |
| Part 6 | 6 | [Test Private Endpoint ⚠️ manual](#m07-part-6--test-private-endpoint) |

### M08 — Monitor Load Balancer
| Tasks | Section |
|-------|---------|
| 1 | [VNet + Bastion](#m08-vnet--bastion) |
| 2-5 | [Load Balancer + Rules](#m08-load-balancer--rules) |
| 6-7 | [Backend VMs + IIS + Backend Pool](#m08-backend-vms) |
| 8 | [Test LB ⚠️ manual](#m08-test-lb) |
| 9 | [Log Analytics Workspace](#m08-log-analytics-workspace) |
| 10-12 | [Monitor Views ⚠️ manual](#m08-monitor-views) |
| 13 | [Diagnostic Settings](#m08-diagnostic-settings) |

---

## M01 Variables

> Run this block first. Variables do not persist when you close the terminal.

<details>
<summary>Show variables</summary>

```powershell
# General
$RG                 = "ContosoResourceGrouplod61979644"
$LOCATION_EASTUS    = "eastus"
$LOCATION_WESTEU    = "westeurope"
$LOCATION_SOUTHASIA = "southeastasia"

# CoreServicesVnet
$VNET1_NAME      = "CoreServicesVnet"       ; $VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_SUB1_NAME = "GatewaySubnet"          ; $VNET1_SUB1      = "10.20.0.0/27"
$VNET1_SUB2_NAME = "DatabaseSubnet"         ; $VNET1_SUB2      = "10.20.20.0/24"
$VNET1_SUB3_NAME = "SharedServicesSubnet"   ; $VNET1_SUB3      = "10.20.10.0/24"
$VNET1_SUB4_NAME = "PublicWebServiceSubnet" ; $VNET1_SUB4      = "10.20.30.0/24"

# ManufacturingVnet
$VNET2_NAME      = "ManufacturingVnet"          ; $VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"  ; $VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"              ; $VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"              ; $VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"              ; $VNET2_SUB4      = "10.30.22.0/24"

# ResearchVnet
$VNET3_NAME      = "ResearchVnet"         ; $VNET3_PREFIX    = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet" ; $VNET3_SUB1      = "10.40.0.0/24"

# DNS (Part 6)
$DNS_ZONE      = "Contoso.com"
$DNS_LINK_NAME = "CoreServicesVnetLink"

# VMs Part 6
$VM1_NAME  = "testvm1" ; $NIC1_NAME = "testvm1-nic" ; $NSG1_NAME = "testvm1-nsg" ; $PIP1_NAME = "testvm1-pip"
$VM2_NAME  = "testvm2" ; $NIC2_NAME = "testvm2-nic" ; $NSG2_NAME = "testvm2-nsg" ; $PIP2_NAME = "testvm2-pip"

# VM Part 8
$MFG_VM_NAME     = "ManufacturingVM"          ; $MFG_SUBNET_NAME = "ManufacturingSystemSubnet"
$MFG_NIC_NAME    = "ManufacturingVM-nic"
$MFG_NSG_NAME    = "ManufacturingVM-nsg"
$MFG_PIP_NAME    = "ManufacturingVM-pip"

# Peerings Part 8
$PEERING1_NAME = "CoreServicesVnet-to-ManufacturingVnet"
$PEERING2_NAME = "ManufacturingVnet-to-CoreServicesVnet"

$VM_SIZE    = "Standard_D2s_v3"
$ADMIN_USER = "TestUser"
```

</details>

---

## M02 Variables

> Run this block first in any M02 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$RG              = "ContosoResourceGroup"
$LOCATION_EASTUS = "eastus"
$LOCATION_WESTEU = "westeurope"

# CoreServicesVnet
$VNET1_NAME      = "CoreServicesVnet"       ; $VNET1_PREFIX    = "10.20.0.0/16"
$VNET1_GW_NAME   = "GatewaySubnet"          ; $VNET1_GW        = "10.20.0.0/27"
$VNET1_SUB1_NAME = "DatabaseSubnet"         ; $VNET1_SUB1      = "10.20.20.0/24"
$VNET1_SUB2_NAME = "SharedServicesSubnet"   ; $VNET1_SUB2      = "10.20.10.0/24"
$VNET1_SUB3_NAME = "PublicWebServiceSubnet" ; $VNET1_SUB3      = "10.20.30.0/24"

# ManufacturingVnet
$VNET2_NAME      = "ManufacturingVnet"          ; $VNET2_PREFIX    = "10.30.0.0/16"
$VNET2_GW_NAME   = "GatewaySubnet"              ; $VNET2_GW        = "10.30.0.0/27"
$VNET2_SUB1_NAME = "ManufacturingSystemSubnet"  ; $VNET2_SUB1      = "10.30.10.0/24"
$VNET2_SUB2_NAME = "SensorSubnet1"              ; $VNET2_SUB2      = "10.30.20.0/24"
$VNET2_SUB3_NAME = "SensorSubnet2"              ; $VNET2_SUB3      = "10.30.21.0/24"
$VNET2_SUB4_NAME = "SensorSubnet3"              ; $VNET2_SUB4      = "10.30.22.0/24"

# ResearchVnet (Part 7)
$VNET3_NAME      = "ResearchVnet"         ; $VNET3_PREFIX    = "10.40.0.0/16"
$VNET3_SUB1_NAME = "ResearchSystemSubnet" ; $VNET3_SUB1      = "10.40.0.0/24"

# VPN Gateways
$GW1_NAME = "CoreServicesVnetGateway"  ; $GW1_PIP = "CoreServicesVnetGateway-ip"
$GW2_NAME = "ManufacturingVnetGateway" ; $GW2_PIP = "ManufacturingVnetGateway-ip"
$GW_SKU   = "VpnGw1AZ"                 ; $GW_GEN  = "Generation1"

# VPN Connections
$CONN1_NAME = "CoreServicesGW-to-ManufacturingGW"
$CONN2_NAME = "ManufacturingGW-to-CoreServicesGW"
$SHARED_KEY = "abc123"

# VMs Part 3
$VM1_NAME = "CoreServicesVM"  ; $VM1_NIC = "CoreServicesVM-nic"  ; $VM1_NSG = "CoreServicesVM-nsg"  ; $VM1_PIP = "CoreServicesVM-pip"
$VM2_NAME = "ManufacturingVM" ; $VM2_NIC = "ManufacturingVM-nic" ; $VM2_NSG = "ManufacturingVM-nsg" ; $VM2_PIP = "ManufacturingVM-pip"
$VM_SIZE    = "Standard_D2s_v3"
$ADMIN_USER = "TestUser"

# Virtual WAN (Part 7)
$VWAN_NAME  = "ContosoVirtualWAN" ; $HUB_NAME  = "ContosoHub"
$HUB_PREFIX = "10.60.0.0/24"      ; $VWAN_CONN = "ContosoVirtualWAN-to-ResearchVNet"
# Note: $VWAN_RG is the same as $RG
```

</details>

---

## M03 Variables

> Run this block first in any M03 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$RG_CORE   = "ContosoResourceGroup"
$RG_ER     = "ExpressRouteResourceGroup"
$LOCATION  = "eastus"
$LOCATION2 = "eastus2"

# Part 4 - ExpressRoute Gateway
$VNET_NAME   = "CoreServicesVNet"           ; $VNET_PREFIX = "10.20.0.0/16"
$GW_SUB_NAME = "GatewaySubnet"              ; $GW_SUB      = "10.20.0.0/27"
$GW_NAME     = "CoreServicesVnetGateway"
$GW_PIP      = "CoreServicesVnetGateway-ip"
$GW_SKU      = "Standard"

# Part 5 - ExpressRoute Circuit
$ER_NAME     = "TestERCircuit"
$ER_LOCATION = "eastus2"
$ER_PEERING  = "Seattle"
$ER_PROVIDER = "Equinix"
$ER_BW       = 50
$ER_SKU      = "Standard"
$ER_BILLING  = "MeteredData"
```

</details>

---

## M04 Variables

> Run this block first in any M04 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$RG              = "IntLB-RG"
$RG_TM           = "Contoso-RG"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"

# Part 4 - VNet
$VNET_NAME      = "IntLB-VNet"   ; $VNET_PREFIX    = "10.1.0.0/16"
$SUBNET_BE_NAME = "myBackendSubnet"  ; $SUBNET_BE      = "10.1.0.0/24"
$SUBNET_FE_NAME = "myFrontEndSubnet" ; $SUBNET_FE      = "10.1.2.0/24"
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

## M05 Variables

> Run this block first in any M05 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$RG              = "ContosoResourceGroup"
$LOCATION        = "eastus"
$LOCATION_WESTEU = "westeurope"

# Part 4 - VNet & Subnets
$VNET_NAME      = "ContosoVNet"    ; $VNET_PREFIX    = "10.0.0.0/16"
$SUBNET_AG_NAME = "AGSubnet"       ; $SUBNET_AG      = "10.0.0.0/24"
$SUBNET_BE_NAME = "BackendSubnet"  ; $SUBNET_BE      = "10.0.1.0/24"

# Part 4 - Application Gateway
$AG_NAME         = "ContosoAppGateway"
$AG_PIP_NAME     = "AGPublicIPAddress"
$AG_BE_POOL      = "BackendPool"
$AG_LISTENER     = "Listener"
$AG_RULE_NAME    = "RoutingRule"
$AG_HTTP_SETTING = "HTTPSetting"

# Part 4 - Backend VMs
$VM1_NAME   = "BackendVM1"
$VM2_NAME   = "BackendVM2"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

# Part 6 - Web Apps
$APP_PLAN_EASTUS = "ContosoAppPlan-EastUS"
$APP_PLAN_WESTEU = "ContosoAppPlan-WestEU"
$WEBAPP1_NAME    = "ContosoWebApp1"
$WEBAPP2_NAME    = "ContosoWebApp2"

# Part 6 - Front Door
$FD_NAME         = "ContosoFrontDoor"
$FD_ORIGIN_GROUP = "default-origin-group"
```

</details>

---

## M06 Variables

> Run this block first in any M06 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$LOCATION = "eastus"

# Part 4 - DDoS
$RG_DDOS         = "MyResourceGroup"
$DDOS_PLAN       = "MyDdosProtectionPlan"
$VNET_DDOS       = "MyVirtualNetwork"   ; $VNET_DDOS_PFX   = "10.1.0.0/16"
$SUBNET_DDOS     = "MySubnet"           ; $SUBNET_DDOS_PFX = "10.1.0.0/24"
$PIP_DDOS        = "MyPublicIPAddress"
$PIP_DNS         = "mypublicdns"        # Must be globally unique — change if needed

# Part 7 - Firewall
$RG_FW         = "Test-FW-RG"
$VNET_FW       = "Test-FW-VN"       ; $VNET_FW_PFX   = "10.0.0.0/16"
$SUBNET_FW     = "AzureFirewallSubnet" ; $SUBNET_FW_PFX = "10.0.1.0/26"
$SUBNET_WL     = "Workload-SN"         ; $SUBNET_WL_PFX = "10.0.2.0/24"
$FW_NAME       = "Test-FW01"
$FW_PIP        = "fw-pip"
$FW_POLICY     = "fw-test-pol"
$ROUTE_TABLE   = "Firewall-route"
$ROUTE_NAME    = "fw-dg"
$SRV_WORK      = "Srv-Work"
$VM_SIZE       = "Standard_DS2_v3"
$ADMIN_USER    = "TestUser"

# Part 7 - Firewall rule collection names
$APP_RULE_COLL  = "App-Coll01"
$NET_RULE_COLL  = "Net-Coll01"
$DNAT_RULE_COLL = "DNAT-Coll01"

# Part 9 - Firewall Manager
$RG_FM        = "fw-manager-rg"
$VWAN_FM      = "Vwan-Hub"          # Used only in New-AzVirtualWan — referenced as $vwan object
$HUB_FM       = "Hub-01"            ; $HUB_FM_PFX   = "10.2.0.0/24"
$SPOKE01      = "Spoke-01"          ; $SPOKE01_PFX  = "10.0.0.0/16"
$SPOKE01_SUB  = "Workload-01-SN"    ; $SPOKE01_SPFX = "10.0.1.0/24"
$SPOKE02      = "Spoke-02"          ; $SPOKE02_PFX  = "10.1.0.0/16"
$SPOKE02_SUB  = "Workload-02-SN"    ; $SPOKE02_SPFX = "10.1.1.0/24"
$FW_POLICY_FM = "Policy-01"
$SRV_WL01     = "Srv-workload-01"
$SRV_WL02     = "Srv-workload-02"
```

</details>

---

## M07 Variables

> Run this block first in any M07 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$LOCATION = "eastus"

# Part 5 - Service Endpoints
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

# Part 6 - Private Endpoint
$RG_PE          = "CreatePrivateEndpointQS-rg"
$VNET_PE        = "myVNet"             ; $VNET_PE_PFX    = "10.0.0.0/16"
$SUBNET_PE      = "myBackendSubnet"    ; $SUBNET_PE_PFX  = "10.0.0.0/24"
$SUBNET_BASTION = "10.0.1.0/24"       # Used as AddressPrefix for AzureBastionSubnet
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

## M08 Variables

> Run this block first in any M08 session.

<details>
<summary>Show variables</summary>

```powershell
# General
$RG       = "IntLB-RG"
$LOCATION = "eastus"

# VNet
$VNET_NAME      = "myVNet"             ; $VNET_PREFIX    = "10.1.0.0/16"
$SUBNET_BE_NAME = "myBackendSubnet"    ; $SUBNET_BE      = "10.1.0.0/24"
$SUBNET_FE_NAME = "myFrontEndSubnet"   ; $SUBNET_FE      = "10.1.2.0/24"
$SUBNET_BH_NAME = "AzureBastionSubnet" ; $SUBNET_BH      = "10.1.1.0/26"
$BASTION_NAME   = "myBastionHost"
$BASTION_PIP    = "myBastionIP"

# Load Balancer
$LB_NAME       = "myIntLoadBalancer"
$LB_FE_NAME    = "LoadBalancerFrontEnd"
$LB_BE_NAME    = "myBackendPool"
$LB_PROBE_NAME = "myHealthProbe"
$LB_RULE_NAME  = "myHTTPRule"

# Backend VMs
$VM1_NAME   = "myVM1" ; $VM2_NAME = "myVM2" ; $VM3_NAME = "myVM3"
$NSG_NAME   = "myNSG"
$AVSET_NAME = "myAvailabilitySet"
$VM_SIZE    = "Standard_DS2_v3"
$ADMIN_USER = "TestUser"

# Log Analytics
$LAW_NAME  = "myLAWorkspace"
$DIAG_NAME = "myLBDiagnostics"
```

</details>

---

## M01 Part 4 — Create VNets & Subnets

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS
Get-AzResourceGroup -Name $RG

# CoreServicesVnet - East US
$gw  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB4_NAME -AddressPrefix $VNET1_SUB4
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX -Subnet $gw,$db,$ss,$web

# ManufacturingVnet - West Europe
$mfg  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$sen1 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$sen2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$sen3 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VNET2_NAME -AddressPrefix $VNET2_PREFIX -Subnet $mfg,$sen1,$sen2,$sen3

# ResearchVnet - Southeast Asia
$res = New-AzVirtualNetworkSubnetConfig -Name $VNET3_SUB1_NAME -AddressPrefix $VNET3_SUB1
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_SOUTHASIA -Name $VNET3_NAME -AddressPrefix $VNET3_PREFIX -Subnet $res
```

</details>

---

## M01 Part 4 — Verify VNets

<details>
<summary>Show code</summary>

```powershell
Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME) | Select-Object Name, AddressPrefix

Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME) | Select-Object Name, AddressPrefix

Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME) | Select-Object Name, AddressPrefix

Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location, AddressSpace
```

</details>

---

## M01 Part 6 — Private DNS Zone

<details>
<summary>Show code</summary>

```powershell
New-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
Get-AzPrivateDnsZone -ResourceGroupName $RG -Name $DNS_ZONE
```

</details>

---

## M01 Part 6 — VNet Link

<details>
<summary>Show code</summary>

```powershell
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG -ZoneName $DNS_ZONE -Name $DNS_LINK_NAME -VirtualNetworkId $vnet.Id -EnableRegistration
Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RG -ZoneName $DNS_ZONE -Name $DNS_LINK_NAME
```

</details>

---

## M01 Part 6 — testvm1 + testvm2

<details>
<summary>Show code</summary>

```powershell
$adminPassword = Read-Host "Password for the VMs" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet          = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$subnetId      = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $VNET1_SUB2_NAME).Id

# testvm1
$pip1     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $PIP1_NAME -Sku Standard -AllocationMethod Static
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg1     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NSG1_NAME -SecurityRules $nsgRule1
$nic1     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NIC1_NAME -SubnetId $subnetId -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
$vm1Config = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic1.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm1Config

# testvm2
$pip2     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $PIP2_NAME -Sku Standard -AllocationMethod Static
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg2     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NSG2_NAME -SecurityRules $nsgRule2
$nic2     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $NIC2_NAME -SubnetId $subnetId -PublicIpAddressId $pip2.Id -NetworkSecurityGroupId $nsg2.Id
$vm2Config = New-AzVMConfig -VMName $VM2_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM2_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic2.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm2Config
Get-AzVM -ResourceGroupName $RG | Select-Object Name, Location
```

</details>

---

## M01 Part 6 — Verify DNS

<details>
<summary>Show code</summary>

```powershell
Get-AzPrivateDnsRecordSet -ResourceGroupName $RG -ZoneName $DNS_ZONE -RecordType A
```

</details>

---

## M01 Part 8 — ManufacturingVM

<details>
<summary>Show code</summary>

```powershell
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$subnetId2 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet2 -Name $MFG_SUBNET_NAME).Id
$pip       = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_PIP_NAME -Sku Standard -AllocationMethod Static
$nsgRule   = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg       = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_NSG_NAME -SecurityRules $nsgRule
$nic       = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $MFG_NIC_NAME -SubnetId $subnetId2 -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id
$vmConfig  = New-AzVMConfig -VMName $MFG_VM_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $MFG_VM_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_WESTEU -VM $vmConfig
Get-AzVM -ResourceGroupName $RG -Name $MFG_VM_NAME | Select-Object Name, Location
```

</details>

---

## M01 Part 8 — RDP + Tests

> ⚠️ Manual step — connect via RDP and run `Test-NetConnection` inside the VMs.

| Step | VM | Command | Expected |
|------|----|---------|----------|
| Before peering | ManufacturingVM | `Test-NetConnection 10.20.20.4 -port 3389` | `False` |
| After peering | ManufacturingVM | `Test-NetConnection 10.20.20.4 -port 3389` | `True` |

---

## M01 Part 8 — VNet Peering

<details>
<summary>Show code</summary>

```powershell
$vnet1 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$vnet2 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
Add-AzVirtualNetworkPeering -Name $PEERING1_NAME -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.Id -AllowForwardedTraffic
Add-AzVirtualNetworkPeering -Name $PEERING2_NAME -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.Id -AllowForwardedTraffic
Get-AzVirtualNetworkPeering -ResourceGroupName $RG -VirtualNetworkName $VNET1_NAME | Select-Object Name, PeeringState
Get-AzVirtualNetworkPeering -ResourceGroupName $RG -VirtualNetworkName $VNET2_NAME | Select-Object Name, PeeringState
```

</details>

---

## M02 Part 3 — Create VNets

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION_EASTUS

$gw1 = New-AzVirtualNetworkSubnetConfig -Name $VNET1_GW_NAME   -AddressPrefix $VNET1_GW
$db  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB1_NAME -AddressPrefix $VNET1_SUB1
$ss  = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB2_NAME -AddressPrefix $VNET1_SUB2
$web = New-AzVirtualNetworkSubnetConfig -Name $VNET1_SUB3_NAME -AddressPrefix $VNET1_SUB3
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET1_NAME -AddressPrefix $VNET1_PREFIX -Subnet $gw1,$db,$ss,$web

$gw2  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_GW_NAME   -AddressPrefix $VNET2_GW
$mfg  = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB1_NAME -AddressPrefix $VNET2_SUB1
$sen1 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB2_NAME -AddressPrefix $VNET2_SUB2
$sen2 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB3_NAME -AddressPrefix $VNET2_SUB3
$sen3 = New-AzVirtualNetworkSubnetConfig -Name $VNET2_SUB4_NAME -AddressPrefix $VNET2_SUB4
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VNET2_NAME -AddressPrefix $VNET2_PREFIX -Subnet $gw2,$mfg,$sen1,$sen2,$sen3

Get-AzVirtualNetwork -ResourceGroupName $RG | Select-Object Name, Location
```

</details>

---

## M02 Part 3 — CoreServicesVM + MfgVM

<details>
<summary>Show code</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

# CoreServicesVM - East US
$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$subnetId1 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet1 -Name $VNET1_SUB1_NAME).Id
$pip1     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_PIP -Sku Standard -AllocationMethod Static
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg1     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NSG -SecurityRules $nsgRule1
$nic1     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VM1_NIC -SubnetId $subnetId1 -PublicIpAddressId $pip1.Id -NetworkSecurityGroupId $nsg1.Id
$vm1Config = New-AzVMConfig -VMName $VM1_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM1_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic1.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_EASTUS -VM $vm1Config

# ManufacturingVM - West Europe
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$subnetId2 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet2 -Name $VNET2_SUB1_NAME).Id
$pip2     = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_PIP -Sku Standard -AllocationMethod Static
$nsgRule2 = New-AzNetworkSecurityRuleConfig -Name "default-allow-rdp" -Priority 1000 -Protocol Tcp -Access Allow -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg2     = New-AzNetworkSecurityGroup -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_NSG -SecurityRules $nsgRule2
$nic2     = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $VM2_NIC -SubnetId $subnetId2 -PublicIpAddressId $pip2.Id -NetworkSecurityGroupId $nsg2.Id
$vm2Config = New-AzVMConfig -VMName $VM2_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $VM2_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic2.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION_WESTEU -VM $vm2Config
Get-AzVM -ResourceGroupName $RG | Select-Object Name, Location
```

</details>

---

## M02 Part 3 — RDP + Tests

> ⚠️ Manual step — connect via RDP and test connectivity before creating the gateways.

| Step | VM | Command | Expected |
|------|----|---------|----------|
| Before gateways | ManufacturingVM | `Test-NetConnection <IP_CoreServicesVM> -port 3389` | `False` |
| After gateways | ManufacturingVM | `Test-NetConnection <IP_CoreServicesVM> -port 3389` | `True` |

---

## M02 Part 3 — VPN Gateways

> ⏱️ Takes up to 45 minutes each. Run both without waiting between them.

<details>
<summary>Show code</summary>

```powershell
# CoreServicesVnetGateway — East US
$pipGw1    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet1     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET1_NAME
$gwSubnet1 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
$gwIp1     = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig1" -SubnetId $gwSubnet1.Id -PublicIpAddressId $pipGw1.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $GW1_NAME -IpConfigurations $gwIp1 -GatewayType VPN -VpnType RouteBased -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN

# ManufacturingVnetGateway — West Europe
$pipGw2    = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_PIP -Sku Standard -AllocationMethod Static -Zone 1,2,3
$vnet2     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET2_NAME
$gwSubnet2 = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2
$gwIp2     = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig2" -SubnetId $gwSubnet2.Id -PublicIpAddressId $pipGw2.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $GW2_NAME -IpConfigurations $gwIp2 -GatewayType VPN -VpnType RouteBased -GatewaySku $GW_SKU -VpnGatewayGeneration $GW_GEN

# Check status — wait for Succeeded on both before proceeding
Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME | Select-Object Name, ProvisioningState
Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME | Select-Object Name, ProvisioningState
```

</details>

---

## M02 Part 3 — VPN Connections

> ⛔ Only run after both gateways show `ProvisioningState = Succeeded`.

<details>
<summary>Show code</summary>

```powershell
$gw1Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW1_NAME
$gw2Obj = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name $GW2_NAME
New-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $CONN1_NAME -ConnectionType Vnet2Vnet -VirtualNetworkGateway1 $gw1Obj -VirtualNetworkGateway2 $gw2Obj -SharedKey $SHARED_KEY -EnableBgp $false
New-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $CONN2_NAME -ConnectionType Vnet2Vnet -VirtualNetworkGateway1 $gw2Obj -VirtualNetworkGateway2 $gw1Obj -SharedKey $SHARED_KEY -EnableBgp $false
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN1_NAME | Select-Object Name, ConnectionStatus
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $RG -Name $CONN2_NAME | Select-Object Name, ConnectionStatus
```

</details>

---

## M02 Part 7 — Virtual WAN

<details>
<summary>Show code</summary>

```powershell
New-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME -Location $LOCATION_EASTUS -VirtualWANType Standard
Get-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME | Select-Object Name, Location, ProvisioningState
```

</details>

---

## M02 Part 7 — Virtual Hub

> ⏱️ Takes up to 30 minutes. Do not connect the VNet until the Hub shows `Succeeded`.

<details>
<summary>Show code</summary>

```powershell
New-AzVirtualHub `
  -ResourceGroupName $RG -Name $HUB_NAME -Location $LOCATION_EASTUS `
  -VirtualWan (Get-AzVirtualWan -ResourceGroupName $RG -Name $VWAN_NAME) `
  -AddressPrefix $HUB_PREFIX
Get-AzVirtualHub -ResourceGroupName $RG -Name $HUB_NAME | Select-Object Name, ProvisioningState
```

</details>

---

## M02 Part 7 — Connect ResearchVnet

> ⛔ Only run after the Hub shows `Succeeded`.

<details>
<summary>Show code</summary>

```powershell
$res   = New-AzVirtualNetworkSubnetConfig -Name $VNET3_SUB1_NAME -AddressPrefix $VNET3_SUB1
New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION_EASTUS -Name $VNET3_NAME -AddressPrefix $VNET3_PREFIX -Subnet $res
$vnet3 = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET3_NAME
New-AzVirtualHubVnetConnection -ResourceGroupName $RG -VirtualHubName $HUB_NAME -Name $VWAN_CONN -RemoteVirtualNetwork $vnet3
Get-AzVirtualHubVnetConnection -ResourceGroupName $RG -VirtualHubName $HUB_NAME -Name $VWAN_CONN | Select-Object Name, ProvisioningState
```

</details>

---

## M03 Part 4 — VNet + GatewaySubnet

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG_CORE -Location $LOCATION
$gwSub = New-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -AddressPrefix $GW_SUB
New-AzVirtualNetwork -ResourceGroupName $RG_CORE -Location $LOCATION -Name $VNET_NAME -AddressPrefix $VNET_PREFIX -Subnet $gwSub
Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME | Select-Object Name, Location, AddressSpace
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME) | Select-Object Name, AddressPrefix
```

</details>

---

## M03 Part 4 — ExpressRoute Gateway

> ⏱️ Takes up to 45 minutes. `GatewayType ExpressRoute` — different from VPN Gateway in M02.

<details>
<summary>Show code</summary>

```powershell
$pipGw = New-AzPublicIpAddress -ResourceGroupName $RG_CORE -Location $LOCATION -Name $GW_PIP -Sku Standard -AllocationMethod Static
$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_CORE -Name $VNET_NAME
$gwSub = Get-AzVirtualNetworkSubnetConfig -Name $GW_SUB_NAME -VirtualNetwork $vnet
$gwIp  = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig" -SubnetId $gwSub.Id -PublicIpAddressId $pipGw.Id
New-AzVirtualNetworkGateway -ResourceGroupName $RG_CORE -Location $LOCATION -Name $GW_NAME -IpConfigurations $gwIp -GatewayType ExpressRoute -GatewaySku $GW_SKU
Get-AzVirtualNetworkGateway -ResourceGroupName $RG_CORE -Name $GW_NAME | Select-Object Name, GatewayType, ProvisioningState
```

</details>

---

## M03 Part 5 — ExpressRoute Circuit

> ⚠️ Billing starts as soon as the Service Key is issued.

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG_ER -Location $LOCATION2
New-AzExpressRouteCircuit `
  -ResourceGroupName $RG_ER -Location $ER_LOCATION -Name $ER_NAME `
  -SkuFamily $ER_BILLING -SkuTier $ER_SKU -ServiceProviderName $ER_PROVIDER `
  -PeeringLocation $ER_PEERING -BandwidthInMbps $ER_BW
```

</details>

---

## M03 Part 5 — Service Key

<details>
<summary>Show code</summary>

```powershell
$circuit = Get-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME
Write-Host "Service Key: $($circuit.ServiceKey)"
Write-Host "Provider Status: $($circuit.ServiceProviderProvisioningState)"
Write-Host "Circuit Status: $($circuit.CircuitProvisioningState)"
```

</details>

---

## M03 Part 5 — Deprovision

> ⛔ Only delete after `ProviderStatus = NotProvisioned`. Billing continues until then.

<details>
<summary>Show code</summary>

```powershell
Remove-AzExpressRouteCircuit -ResourceGroupName $RG_ER -Name $ER_NAME -Force
Remove-AzResourceGroup -Name $RG_CORE -Force -AsJob
Remove-AzResourceGroup -Name $RG_ER   -Force -AsJob
```

</details>

---

## M04 Part 4 — VNet + Bastion

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION
$subnetBe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -AddressPrefix $SUBNET_BE
$subnetFe      = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FE_NAME -AddressPrefix $SUBNET_FE
$subnetBastion = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix $BASTION_SUBNET
$vnet = New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION -Name $VNET_NAME -AddressPrefix $VNET_PREFIX -Subnet $subnetBe,$subnetFe,$subnetBastion
$bastionPip = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION -Name $BASTION_PIP -Sku Standard -AllocationMethod Static
New-AzBastion -ResourceGroupName $RG -Name $BASTION_NAME -VirtualNetwork $vnet -PublicIpAddress $bastionPip
Get-AzVirtualNetworkSubnetConfig -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME) | Select-Object Name, AddressPrefix
```

</details>

---

## M04 Part 4 — Backend VMs

<details>
<summary>Show code</summary>

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

---

## M04 Part 4 — Load Balancer + Rules

<details>
<summary>Show code</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetFe = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FE_NAME
$feConfig = New-AzLoadBalancerFrontendIpConfig -Name $LB_FE_NAME -SubnetId $subnetFe.Id
$lb = New-AzLoadBalancer -ResourceGroupName $RG -Location $LOCATION -Name $LB_NAME -Sku Standard -FrontendIpConfiguration $feConfig

# Backend Pool + add VMs
$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerBackendAddressPoolConfig -Name $LB_BE_NAME | Set-AzLoadBalancer
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
foreach ($vmName in @($VM1_NAME, $VM2_NAME, $VM3_NAME)) {
  $nic = Get-AzNetworkInterface -ResourceGroupName $RG -Name "$vmName-nic"
  $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $bePool
  Set-AzNetworkInterface -NetworkInterface $nic
}

# Health Probe
$lb = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$lb | Add-AzLoadBalancerProbeConfig -Name $LB_PROBE_NAME -Protocol Http -Port 80 -RequestPath "/" -IntervalInSeconds 15 -ProbeCount 2 | Set-AzLoadBalancer

# LB Rule
$lb     = Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME
$feIp   = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $lb -Name $LB_FE_NAME
$bePool = Get-AzLoadBalancerBackendAddressPool -LoadBalancer $lb -Name $LB_BE_NAME
$probe  = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name $LB_PROBE_NAME
$lb | Add-AzLoadBalancerRuleConfig -Name $LB_RULE_NAME -FrontendIpConfiguration $feIp -BackendAddressPool $bePool -Probe $probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 -IdleTimeoutInMinutes 15 -EnableFloatingIP $false | Set-AzLoadBalancer
Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME | Select-Object Name, ProvisioningState
```

</details>

---

## M04 Part 4 — Test VM

<details>
<summary>Show code</summary>

```powershell
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id
$nic = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION -Name $TESTVM_NIC -SubnetId $subnetId -NetworkSecurityGroupId $nsg.Id
$vmConfig = New-AzVMConfig -VMName $TESTVM_NAME -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $TESTVM_NAME -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-Datacenter-Core -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig
Get-AzVM -ResourceGroupName $RG -Name $TESTVM_NAME | Select-Object Name, ProvisioningState
```

</details>

---

## M04 Part 4 — Test LB

> ⚠️ Manual step — connect via Bastion and test in browser.

```powershell
# Get the LB Private IP
(Get-AzLoadBalancer -ResourceGroupName $RG -Name $LB_NAME).FrontendIpConfigurations[0].PrivateIpAddress
```

Connect to `myTestVM` via Bastion, open browser, navigate to the LB Private IP. Refresh to see responses from different VMs.

---

## M04 Part 6 — Web Apps

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG_TM -Location $LOCATION
New-AzAppServicePlan -ResourceGroupName $RG_TM -Location $LOCATION -Name "$APP_PLAN_NAME-EastUS" -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG_TM -Location $LOCATION -AppServicePlan "$APP_PLAN_NAME-EastUS" -Name $WEBAPP1_NAME
New-AzAppServicePlan -ResourceGroupName $RG_TM -Location $LOCATION_WESTEU -Name "$APP_PLAN_NAME-WestEU" -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG_TM -Location $LOCATION_WESTEU -AppServicePlan "$APP_PLAN_NAME-WestEU" -Name $WEBAPP2_NAME
Get-AzWebApp -ResourceGroupName $RG_TM | Select-Object Name, Location, State
```

</details>

---

## M04 Part 6 — Traffic Manager Profile

<details>
<summary>Show code</summary>

```powershell
New-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE -TrafficRoutingMethod Priority -RelativeDnsName $TM_PROFILE -Ttl 30 -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath "/"
Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE | Select-Object Name, TrafficRoutingMethod, ProfileStatus
```

</details>

---

## M04 Part 6 — Traffic Manager Endpoints

<details>
<summary>Show code</summary>

```powershell
$app1 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG_TM -Name $WEBAPP2_NAME
New-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Name $TM_EP1_NAME -Type AzureEndpoints -TargetResourceId $app1.Id -EndpointStatus Enabled -Priority 1
New-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Name $TM_EP2_NAME -Type AzureEndpoints -TargetResourceId $app2.Id -EndpointStatus Enabled -Priority 2
Get-AzTrafficManagerEndpoint -ResourceGroupName $RG_TM -ProfileName $TM_PROFILE -Type AzureEndpoints | Select-Object Name, EndpointStatus, Priority
```

</details>

---

## M04 Part 6 — Test Traffic Manager

> ⚠️ Manual step — test in browser.

```powershell
# Get the Traffic Manager DNS
(Get-AzTrafficManagerProfile -ResourceGroupName $RG_TM -Name $TM_PROFILE).DnsConfig.Fqdn
```

Navigate to that DNS in browser — should resolve to East US. Disable East US endpoint to test failover to West Europe.

---

## M05 Part 4 — Application Gateway

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG -Location $LOCATION
$subnetAg = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_AG_NAME -AddressPrefix $SUBNET_AG
$vnet = New-AzVirtualNetwork -ResourceGroupName $RG -Location $LOCATION -Name $VNET_NAME -AddressPrefix $VNET_PREFIX -Subnet $subnetAg
$agPip = New-AzPublicIpAddress -ResourceGroupName $RG -Location $LOCATION -Name $AG_PIP_NAME -Sku Standard -AllocationMethod Static
$agSubnet    = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_AG_NAME
$agIpConfig  = New-AzApplicationGatewayIPConfiguration -Name "agIPConfig" -Subnet $agSubnet
$feIpConfig  = New-AzApplicationGatewayFrontendIPConfig -Name "feFrontendIp" -PublicIPAddress $agPip
$fePort      = New-AzApplicationGatewayFrontendPort -Name "fePort" -Port 80
$bePool      = New-AzApplicationGatewayBackendAddressPool -Name $AG_BE_POOL
$beHttpSettings = New-AzApplicationGatewayBackendHttpSetting -Name $AG_HTTP_SETTING -Port 80 -Protocol Http -CookieBasedAffinity Disabled -RequestTimeout 20
$listener    = New-AzApplicationGatewayHttpListener -Name $AG_LISTENER -Protocol Http -FrontendIPConfiguration $feIpConfig -FrontendPort $fePort
$routingRule = New-AzApplicationGatewayRequestRoutingRule -Name $AG_RULE_NAME -RuleType Basic -Priority 100 -HttpListener $listener -BackendAddressPool $bePool -BackendHttpSettings $beHttpSettings
$sku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2
New-AzApplicationGateway -ResourceGroupName $RG -Location $LOCATION -Name $AG_NAME -GatewayIPConfigurations $agIpConfig -FrontendIPConfigurations $feIpConfig -FrontendPorts $fePort -BackendAddressPools $bePool -BackendHttpSettingsCollection $beHttpSettings -HttpListeners $listener -RequestRoutingRules $routingRule -Sku $sku
Get-AzApplicationGateway -ResourceGroupName $RG -Name $AG_NAME | Select-Object Name, ProvisioningState, OperationalState

# Add BackendSubnet
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
Add-AzVirtualNetworkSubnetConfig -Name $SUBNET_BE_NAME -VirtualNetwork $vnet -AddressPrefix $SUBNET_BE | Set-AzVirtualNetwork
```

</details>

---

## M05 Part 4 — Backend VMs + IIS

<details>
<summary>Show code</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG -Name $VNET_NAME
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_BE_NAME).Id

foreach ($vmName in @($VM1_NAME, $VM2_NAME)) {
  $nic = New-AzNetworkInterface -ResourceGroupName $RG -Location $LOCATION -Name "$vmName-nic" -SubnetId $subnetId
  $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
  New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig -AsJob
}
Get-Job | Wait-Job

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

## M05 Part 4 — Add VMs to Backend Pool

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

## M05 Part 4 — Test App Gateway

> ⚠️ Manual step — test in browser.

```powershell
# Get the Application Gateway public IP
(Get-AzPublicIpAddress -ResourceGroupName $RG -Name $AG_PIP_NAME).IpAddress
```

Open browser, navigate to that IP. Refresh to see responses from BackendVM1 and BackendVM2.

---

## M05 Part 6 — Web Apps

<details>
<summary>Show code</summary>

```powershell
New-AzAppServicePlan -ResourceGroupName $RG -Location $LOCATION -Name $APP_PLAN_EASTUS -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG -Location $LOCATION -AppServicePlan $APP_PLAN_EASTUS -Name $WEBAPP1_NAME
New-AzAppServicePlan -ResourceGroupName $RG -Location $LOCATION_WESTEU -Name $APP_PLAN_WESTEU -Tier Standard -NumberofWorkers 1 -WorkerSize Small
New-AzWebApp -ResourceGroupName $RG -Location $LOCATION_WESTEU -AppServicePlan $APP_PLAN_WESTEU -Name $WEBAPP2_NAME
Get-AzWebApp -ResourceGroupName $RG | Select-Object Name, Location, State
```

</details>

---

## M05 Part 6 — Azure Front Door

<details>
<summary>Show code</summary>

```powershell
$app1 = Get-AzWebApp -ResourceGroupName $RG -Name $WEBAPP1_NAME
$app2 = Get-AzWebApp -ResourceGroupName $RG -Name $WEBAPP2_NAME
$origin1     = New-AzFrontDoorOrigin -Name "webapp1-origin" -HostName $app1.DefaultHostName -HttpPort 80 -HttpsPort 443 -Priority 1 -Weight 1000
$origin2     = New-AzFrontDoorOrigin -Name "webapp2-origin" -HostName $app2.DefaultHostName -HttpPort 80 -HttpsPort 443 -Priority 2 -Weight 1000
$originGroup = New-AzFrontDoorOriginGroup -Name $FD_ORIGIN_GROUP -SessionAffinityState Disabled
$route       = New-AzFrontDoorRoute -Name "default-route" -OriginGroup $originGroup -PatternsToMatch "/*" -SupportedProtocol Http,Https -HttpsRedirect Enabled
New-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME -SkuName Standard_AzureFrontDoor -Origin @($origin1,$origin2) -OriginGroup $originGroup -Route $route
Get-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME | Select-Object Name, ProvisioningState
```

</details>

---

## M05 Part 6 — Test Front Door

> ⚠️ Manual step — test in browser.

```powershell
# Get the Front Door hostname
(Get-AzFrontDoor -ResourceGroupName $RG -Name $FD_NAME).FrontendEndpoints[0].Hostname
```

Navigate to that hostname. Stop one web app to test automatic failover.

---

## M06 Part 4 — DDoS Protection

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG_DDOS -Location $LOCATION
$ddosPlan = New-AzDdosProtectionPlan -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $DDOS_PLAN
Get-AzDdosProtectionPlan -ResourceGroupName $RG_DDOS -Name $DDOS_PLAN | Select-Object Name, ProvisioningState

$subnet = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_DDOS -AddressPrefix $SUBNET_DDOS_PFX
$vnet   = New-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $VNET_DDOS -AddressPrefix $VNET_DDOS_PFX -Subnet $subnet -DdosProtectionPlan $ddosPlan -EnableDdosProtection
Get-AzVirtualNetwork -ResourceGroupName $RG_DDOS -Name $VNET_DDOS | Select-Object Name, EnableDdosProtection
```

</details>

---

## M06 Part 4 — DDoS Telemetry

<details>
<summary>Show code</summary>

```powershell
$pip = New-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Location $LOCATION -Name $PIP_DDOS -Sku Standard -AllocationMethod Static -DomainNameLabel $PIP_DNS
Get-AzPublicIpAddress -ResourceGroupName $RG_DDOS -Name $PIP_DDOS | Select-Object Name, IpAddress, DnsSettings
```

</details>

---

## M06 Part 4 — Diagnostics + Alerts

> ⚠️ Manual step — configure via portal.

- **Diagnostic logs**: DDoS Protection Plan > Monitoring > Diagnostic settings > Enable `DDoSProtectionNotifications`, `DDoSMitigationFlowLogs`, `DDoSMitigationReports`
- **Alerts**: Public IP > Monitoring > Alerts > New alert rule > Metric: `Under DDoS attack or not`
- **Simulation**: Requires BreakingPoint Cloud account at breakingpoint.cloud

---

## M06 Part 7 — Firewall VNet + VM

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG_FW -Location $LOCATION
$subnetFw = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_FW -AddressPrefix $SUBNET_FW_PFX
$subnetWl = New-AzVirtualNetworkSubnetConfig -Name $SUBNET_WL -AddressPrefix $SUBNET_WL_PFX
New-AzVirtualNetwork -ResourceGroupName $RG_FW -Location $LOCATION -Name $VNET_FW -AddressPrefix $VNET_FW_PFX -Subnet $subnetFw,$subnetWl

$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subnetId = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL).Id
$nic = New-AzNetworkInterface -ResourceGroupName $RG_FW -Location $LOCATION -Name "$SRV_WORK-nic" -SubnetId $subnetId
$vmConfig = New-AzVMConfig -VMName $SRV_WORK -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WORK -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id
New-AzVM -ResourceGroupName $RG_FW -Location $LOCATION -VM $vmConfig
$srvWorkIp = (Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name "$SRV_WORK-nic").IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-Work Private IP: $srvWorkIp"
```

</details>

---

## M06 Part 7 — Deploy Firewall

<details>
<summary>Show code</summary>

```powershell
$fwPip    = New-AzPublicIpAddress -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_PIP -Sku Standard -AllocationMethod Static
$fwPolicy = New-AzFirewallPolicy -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_POLICY
$vnet     = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$fwSub    = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_FW
$fwIpConfig = New-AzFirewallIpConfiguration -Name "fwIpConfig" -PublicIPAddress $fwPip -Subnet $fwSub
$firewall   = New-AzFirewall -ResourceGroupName $RG_FW -Location $LOCATION -Name $FW_NAME -Sku Standard -FirewallPolicy $fwPolicy -IpConfiguration $fwIpConfig
$fwPrivateIp = $firewall.IpConfigurations[0].PrivateIPAddress
Write-Host "Firewall Private IP: $fwPrivateIp"
Write-Host "Firewall Public IP:  $($fwPip.IpAddress)"
```

</details>

---

## M06 Part 7 — Default Route

<details>
<summary>Show code</summary>

```powershell
$routeTable = New-AzRouteTable -ResourceGroupName $RG_FW -Location $LOCATION -Name $ROUTE_TABLE -DisableBgpRoutePropagation $false
$routeTable | Add-AzRouteConfig -Name $ROUTE_NAME -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $fwPrivateIp | Set-AzRouteTable
$vnet  = Get-AzVirtualNetwork -ResourceGroupName $RG_FW -Name $VNET_FW
$subWl = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SUBNET_WL
$subWl.RouteTable = $routeTable
Set-AzVirtualNetwork -VirtualNetwork $vnet
```

</details>

---

## M06 Part 7 — Firewall Rules

<details>
<summary>Show code</summary>

```powershell
# Application Rule — allow www.google.com
$appRule = New-AzFirewallPolicyApplicationRule -Name "Allow-Google" -SourceAddress "10.0.2.0/24" -TargetFqdn "www.google.com" -Protocol "http:80","https:443"
$appColl = New-AzFirewallPolicyFilterRuleCollection -Name $APP_RULE_COLL -Priority 200 -ActionType Allow -Rule $appRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
$rcGroup  = New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup01" -Priority 200 -RuleCollection $appColl -FirewallPolicyObject $fwPolicy

# Network Rule — allow DNS
$netRule = New-AzFirewallPolicyNetworkRule -Name "Allow-DNS" -SourceAddress "10.0.2.0/24" -DestinationAddress "209.244.0.3","209.244.0.4" -DestinationPort "53" -Protocol UDP
$netColl = New-AzFirewallPolicyFilterRuleCollection -Name $NET_RULE_COLL -Priority 200 -ActionType Allow -Rule $netRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
$rcGroup2 = New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup02" -Priority 300 -RuleCollection $netColl -FirewallPolicyObject $fwPolicy

# DNAT Rule — RDP to Srv-Work via Firewall public IP
$dnatRule = New-AzFirewallPolicyNatRule -Name "RDP-to-SrvWork" -SourceAddress "*" -DestinationAddress $fwPip.IpAddress -DestinationPort "3389" -Protocol TCP -TranslatedAddress $srvWorkIp -TranslatedPort "3389"
$dnatColl = New-AzFirewallPolicyNatRuleCollection -Name $DNAT_RULE_COLL -Priority 100 -ActionType DNAT -Rule $dnatRule
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FW -Name $FW_POLICY
$rcGroup3 = New-AzFirewallPolicyRuleCollectionGroup -Name "RuleCollectionGroup03" -Priority 100 -RuleCollection $dnatColl -FirewallPolicyObject $fwPolicy
```

</details>

---

## M06 Part 7 — Change DNS

<details>
<summary>Show code</summary>

```powershell
$nic = Get-AzNetworkInterface -ResourceGroupName $RG_FW -Name "$SRV_WORK-nic"
$nic.DnsSettings.DnsServers.Clear()
$nic.DnsSettings.DnsServers.Add("209.244.0.3")
$nic.DnsSettings.DnsServers.Add("209.244.0.4")
Set-AzNetworkInterface -NetworkInterface $nic
```

</details>

---

## M06 Part 7 — Test Firewall

> ⚠️ Manual step — RDP via Firewall public IP.

RDP to `<FW_PUBLIC_IP>:3389` (user: TestUser). Inside Srv-Work:
- `www.google.com` → **allowed** by app rule
- `www.microsoft.com` → **blocked**
- `nslookup www.google.com` → resolves via `209.244.0.3`

---

## M06 Part 9 — Spoke VNets + Secured Hub

> ⏱️ Hub takes up to 30 minutes. Do not connect spokes until `ProvisioningState = Succeeded`.

<details>
<summary>Show code</summary>

```powershell
New-AzResourceGroup -Name $RG_FM -Location $LOCATION
$sub01 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE01_SUB -AddressPrefix $SPOKE01_SPFX
New-AzVirtualNetwork -ResourceGroupName $RG_FM -Location $LOCATION -Name $SPOKE01 -AddressPrefix $SPOKE01_PFX -Subnet $sub01
$sub02 = New-AzVirtualNetworkSubnetConfig -Name $SPOKE02_SUB -AddressPrefix $SPOKE02_SPFX
New-AzVirtualNetwork -ResourceGroupName $RG_FM -Location $LOCATION -Name $SPOKE02 -AddressPrefix $SPOKE02_PFX -Subnet $sub02

$vwan = New-AzVirtualWan -ResourceGroupName $RG_FM -Location $LOCATION -Name $VWAN_FM -VirtualWANType Standard
New-AzVirtualHub -ResourceGroupName $RG_FM -Location $LOCATION -Name $HUB_FM -VirtualWan $vwan -AddressPrefix $HUB_FM_PFX -Sku Standard
Get-AzVirtualHub -ResourceGroupName $RG_FM -Name $HUB_FM | Select-Object Name, ProvisioningState
```

</details>

---

## M06 Part 9 — Connect Hub and Spokes

> ⛔ Only run after Hub shows `Succeeded`.

<details>
<summary>Show code</summary>

```powershell
$spoke01Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$spoke02Vnet = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02
New-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM -Name "hub-spoke-01" -RemoteVirtualNetwork $spoke01Vnet
New-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM -Name "hub-spoke-02" -RemoteVirtualNetwork $spoke02Vnet
Get-AzVirtualHubVnetConnection -ResourceGroupName $RG_FM -VirtualHubName $HUB_FM | Select-Object Name, ProvisioningState
```

</details>

---

## M06 Part 9 — Deploy Workload Servers

<details>
<summary>Show code</summary>

```powershell
$adminPassword = Read-Host "VM Password" -AsSecureString
$credential    = New-Object System.Management.Automation.PSCredential($ADMIN_USER, $adminPassword)

$vnet01     = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE01
$subnetId01 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet01 -Name $SPOKE01_SUB).Id
$nic01 = New-AzNetworkInterface -ResourceGroupName $RG_FM -Location $LOCATION -Name "$SRV_WL01-nic" -SubnetId $subnetId01
$vmConfig01 = New-AzVMConfig -VMName $SRV_WL01 -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WL01 -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic01.Id
New-AzVM -ResourceGroupName $RG_FM -Location $LOCATION -VM $vmConfig01 -AsJob

$vnet02     = Get-AzVirtualNetwork -ResourceGroupName $RG_FM -Name $SPOKE02
$subnetId02 = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet02 -Name $SPOKE02_SUB).Id
$nic02 = New-AzNetworkInterface -ResourceGroupName $RG_FM -Location $LOCATION -Name "$SRV_WL02-nic" -SubnetId $subnetId02
$vmConfig02 = New-AzVMConfig -VMName $SRV_WL02 -VMSize $VM_SIZE | Set-AzVMOperatingSystem -Windows -ComputerName $SRV_WL02 -Credential $credential | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic02.Id
New-AzVM -ResourceGroupName $RG_FM -Location $LOCATION -VM $vmConfig02 -AsJob

Get-Job | Wait-Job
$wl01Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name "$SRV_WL01-nic").IpConfigurations[0].PrivateIpAddress
$wl02Ip = (Get-AzNetworkInterface -ResourceGroupName $RG_FM -Name "$SRV_WL02-nic").IpConfigurations[0].PrivateIpAddress
Write-Host "Srv-workload-01 IP: $wl01Ip"
Write-Host "Srv-workload-02 IP: $wl02Ip"
```

</details>

---

## M06 Part 9 — Firewall Policy

<details>
<summary>Show code</summary>

```powershell
$fwPolicy = New-AzFirewallPolicy -ResourceGroupName $RG_FM -Location $LOCATION -Name $FW_POLICY_FM
$appRule  = New-AzFirewallPolicyApplicationRule -Name "Allow-Microsoft" -SourceAddress "10.0.1.0/24","10.1.1.0/24" -TargetFqdn "www.microsoft.com" -Protocol "http:80","https:443"
$appColl  = New-AzFirewallPolicyFilterRuleCollection -Name "App-Coll01" -Priority 200 -ActionType Allow -Rule $appRule
$netRule1 = New-AzFirewallPolicyNetworkRule -Name "Allow-RDP-Wl01" -SourceAddress "*" -DestinationAddress "10.0.1.4" -DestinationPort "3389" -Protocol TCP
$netRule2 = New-AzFirewallPolicyNetworkRule -Name "Allow-RDP-Wl02" -SourceAddress "*" -DestinationAddress "10.1.1.4" -DestinationPort "3389" -Protocol TCP
$netColl  = New-AzFirewallPolicyFilterRuleCollection -Name "Net-Coll01" -Priority 100 -ActionType Allow -Rule @($netRule1,$netRule2)
$fwPolicy = Get-AzFirewallPolicy -ResourceGroupName $RG_FM -Name $FW_POLICY_FM
New-AzFirewallPol