#!/usr/bin/env bash
set -euo pipefail

declare -A RG_VMS=(
  ["avnm-hubnspoke"]="vm-spoke1 vm-spoke2"
  ["avnm-mesh"]="vm-mesh-1 vm-mesh-2 vm-mesh-3 vm-mesh-4"
  ["avnm-security"]="vm-sec"
)

echo "Stopping all demo VMs..."

for rg in "${!RG_VMS[@]}"; do
  for vm in ${RG_VMS[$rg]}; do
    echo "  Stopping ${vm} in ${rg}..."
    az vm deallocate --resource-group "$rg" --name "$vm" --no-wait
  done
done

echo "Stop commands sent. Check status with:"
echo "  az vm list -d --query [].{name:name,rg:resourceGroup,powerState:powerState} -o table"
