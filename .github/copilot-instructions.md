# Copilot Instructions

## Project Overview

This repo contains Azure infrastructure demos using Bicep. Each demo lives in its own subdirectory (e.g., `avnm/`) with a self-contained deployment. The current demo provisions Azure Virtual Network Manager with mesh and hub-and-spoke VNet topologies — infrastructure only, no AVNM connectivity configuration.

## Build & Validate

```bash
# Validate Bicep from a demo directory (e.g., avnm/)
az bicep build --file main.bicep

# Deploy (subscription-level)
./deploy.sh
# or manually:
az deployment sub create --location swedencentral --template-file main.bicep --parameters main.bicepparam
```

## Architecture

- Each demo directory has a `main.bicep` at **subscription scope** (`targetScope = 'subscription'`) that creates resource groups and deploys modules into them.
- Reusable resource definitions live in `modules/` as Bicep modules.
- `main.bicepparam` holds environment-specific parameter values using the `using` keyword to reference `main.bicep`.
- `deploy.sh` wraps the `az deployment sub create` call with a timestamped deployment name.

## Conventions

- **Bicep modules**: Every Azure resource type gets its own module in `modules/`. Modules accept `name`, `location`, and `tags` as standard parameters. Each module outputs at minimum `id` and `name`.
- **`@description()` decorators**: All parameters must have a `@description()` decorator.
- **VNet addressing**: Use non-overlapping /16 address spaces. Each VNet gets a single `default` subnet using the first /24 of its range.
- **Resource group naming**: Resource group names are defined as string literals in `main.bicep`, not parameterized.
- **API versions**: Use the latest stable Azure API versions (currently 2024-05-01 for networking, 2024-07-01 for resource groups).
- **No peering**: VNets are deployed without peering — connectivity is managed externally via AVNM.
