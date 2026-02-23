#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="avnm-hubnspoke"
VMS=("vm-spoke1" "vm-spoke2")

echo "Starting all demo VMs in ${RESOURCE_GROUP}..."

for vm in "${VMS[@]}"; do
  echo "  Starting ${vm}..."
  az vm start --resource-group "$RESOURCE_GROUP" --name "$vm" --no-wait
done

echo "Start commands sent. Use 'az vm list -g ${RESOURCE_GROUP} -d --query [].{name:name,powerState:powerState} -o table' to check status."
