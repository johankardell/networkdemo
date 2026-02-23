# Azure Virtual Network Manager Demo

Bicep deployment for demoing Azure Virtual Network Manager (AVNM) with mesh connectivity, hub-and-spoke connectivity, and IPAM.

## Resource Layout

| Resource Group | Resources |
|---|---|
| `avnm-manager` | Azure Virtual Network Manager (`avnm-demo`), IPAM pool (`ipam-pool-demo` — 192.168.0.0/16), network groups, connectivity configs |
| `avnm-mesh` | `vnet-1` (10.0.0.0/16), `vnet-2` (10.1.0.0/16), `vnet-3` (10.2.0.0/16), `vnet-4` (10.3.0.0/16) |
| `avnm-hubnspoke` | `vnet-hub` (10.10.0.0/16), `vnet-spoke1` (10.11.0.0/16), `vnet-spoke2` (10.12.0.0/16) |
| `avnm-ipam` | `vnet-ipam-1` (192.168.1.0/24), `vnet-ipam-2` (192.168.2.0/24), `vnet-ipam-3` (192.168.3.0/24) |

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription with permissions to create resource groups and network resources

## Deploy

```bash
az login
az deployment sub create \
  --location swedencentral \
  --template-file main.bicep \
  --parameters main.bicepparam
```

## Clean Up

```bash
az group delete --name avnm-manager --yes --no-wait
az group delete --name avnm-mesh --yes --no-wait
az group delete --name avnm-hubnspoke --yes --no-wait
az group delete --name avnm-ipam --yes --no-wait
```
