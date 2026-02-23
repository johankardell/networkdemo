#!/usr/bin/env bash
set -euo pipefail

LOCATION="swedencentral"
TEMPLATE_FILE="main.bicep"
PARAMS_FILE="main.bicepparam"

# SSH_PUBLIC_KEY is read by main.bicepparam via readEnvironmentVariable
export SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-$(cat ~/.ssh/id_rsa.pub 2>/dev/null || echo '')}"

if [ -z "$SSH_PUBLIC_KEY" ]; then
  echo "Error: Set SSH_PUBLIC_KEY or ensure ~/.ssh/id_rsa.pub exists."
  exit 1
fi

echo "Deploying AVNM demo infrastructure to ${LOCATION}..."

az deployment sub create \
  --location "$LOCATION" \
  --template-file "$TEMPLATE_FILE" \
  --parameters "$PARAMS_FILE" \
  --name "avnm-demo-$(date +%Y%m%d%H%M%S)"

echo "Deployment complete."
