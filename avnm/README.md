# Azure Virtual Network Manager Demo

Bicep deployment for demoing Azure Virtual Network Manager (AVNM) with mesh connectivity, hub-and-spoke connectivity, IPAM, routing, and security admin configurations.

## Resource Layout

| Resource Group | Resources |
|---|---|
| `avnm-manager` | Virtual Network Manager (`avnm-demo`), IPAM pool (`ipam-pool-demo` — 192.168.0.0/16), network groups, connectivity/routing/security configs |
| `avnm-mesh` | `vnet-mesh-1` … `vnet-mesh-4` (10.0–10.3.0.0/16), `vm-mesh-1` … `vm-mesh-4`, Bastion (`bas-mesh`) |
| `avnm-hubnspoke` | `vnet-hub` (10.10.0.0/16), `vnet-spoke1` (10.11.0.0/16), `vnet-spoke2` (10.12.0.0/16), `vm-spoke1`, `vm-spoke2`, Azure Firewall (`fw-hub`), Bastion (`bas-hub`) |
| `avnm-ipam` | `vnet-ipam-1` … `vnet-ipam-3` — addresses allocated dynamically from IPAM pool |
| `avnm-security` | `vnet-sec` (10.20.0.0/16) with `nsg-security`, `vm-sec`, security admin rule (always-allow TCP 9090) |

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription with permissions to create resource groups and network resources
- An SSH key pair at `~/.ssh/id_rsa` (or set `SSH_PUBLIC_KEY` environment variable)

## Deploy

```bash
az login
./deploy.sh
```

The deploy script provisions all infrastructure and then commits the AVNM connectivity, routing, and security admin configurations.

## Helper Scripts

| Script | Description |
|---|---|
| `./deploy.sh` | Deploy infrastructure and commit AVNM configurations |
| `./ssh.sh` | Interactive menu to SSH into any VM via Bastion |
| `./start-vms.sh` | Start all demo VMs |
| `./stop-vms.sh` | Stop (deallocate) all demo VMs |

## Clean Up

```bash
az group delete --name avnm-manager --yes --no-wait
az group delete --name avnm-mesh --yes --no-wait
az group delete --name avnm-hubnspoke --yes --no-wait
az group delete --name avnm-ipam --yes --no-wait
az group delete --name avnm-security --yes --no-wait
```
