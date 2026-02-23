#!/usr/bin/env bash
set -euo pipefail

LOCATION="swedencentral"
TEMPLATE_FILE="main.bicep"
PARAMS_FILE="main.bicepparam"
AVNM_RG="avnm-manager"
AVNM_NAME="avnm-demo"

# SSH_PUBLIC_KEY is read by main.bicepparam via readEnvironmentVariable
export SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-$(cat ~/.ssh/id_rsa.pub 2>/dev/null || echo '')}"

if [ -z "$SSH_PUBLIC_KEY" ]; then
  echo "Error: Set SSH_PUBLIC_KEY or ensure ~/.ssh/id_rsa.pub exists."
  exit 1
fi

echo "Deploying AVNM demo infrastructure to ${LOCATION}..."

DEPLOYMENT_NAME="avnm-demo-$(date +%Y%m%d%H%M%S)"

az deployment sub create \
  --location "$LOCATION" \
  --template-file "$TEMPLATE_FILE" \
  --parameters "$PARAMS_FILE" \
  --name "$DEPLOYMENT_NAME"

echo "Infrastructure deployed. Reading outputs..."

MESH_CONFIG_ID=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query 'properties.outputs.meshConnectivityConfigId.value' -o tsv)
HUBSPOKE_CONFIG_ID=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query 'properties.outputs.hubSpokeConnectivityConfigId.value' -o tsv)
SECURITY_CONFIG_ID=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query 'properties.outputs.securityAdminConfigId.value' -o tsv)
ROUTING_CONFIG_ID=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query 'properties.outputs.routingConfigId.value' -o tsv)

echo "Committing AVNM configurations..."

# Commit connectivity configurations
echo "  Committing connectivity configurations..."
az network manager post-commit \
  --network-manager-name "$AVNM_NAME" \
  --resource-group "$AVNM_RG" \
  --commit-type "Connectivity" \
  --configuration-ids "$MESH_CONFIG_ID" "$HUBSPOKE_CONFIG_ID" \
  --target-locations "$LOCATION"

# Commit routing configuration
echo "  Committing routing configuration..."
az network manager post-commit \
  --network-manager-name "$AVNM_NAME" \
  --resource-group "$AVNM_RG" \
  --commit-type "Routing" \
  --configuration-ids "$ROUTING_CONFIG_ID" \
  --target-locations "$LOCATION"

# Commit security admin configuration
echo "  Committing security admin configuration..."
az network manager post-commit \
  --network-manager-name "$AVNM_NAME" \
  --resource-group "$AVNM_RG" \
  --commit-type "SecurityAdmin" \
  --configuration-ids "$SECURITY_CONFIG_ID" \
  --target-locations "$LOCATION"

echo "Deployment and commit complete."
