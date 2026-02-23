#!/usr/bin/env bash
set -euo pipefail

LOCATION="swedencentral"
TEMPLATE_FILE="main.bicep"
PARAMS_FILE="main.bicepparam"

echo "Deploying AVNM demo infrastructure to ${LOCATION}..."

az deployment sub create \
  --location "$LOCATION" \
  --template-file "$TEMPLATE_FILE" \
  --parameters "$PARAMS_FILE" \
  --name "avnm-demo-$(date +%Y%m%d%H%M%S)"

echo "Deployment complete."
