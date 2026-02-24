#!/usr/bin/env bash
set -euo pipefail

SSH_KEY="${SSH_PRIVATE_KEY:-$HOME/.ssh/id_rsa}"

if [ ! -f "$SSH_KEY" ]; then
  echo "Error: SSH private key not found at $SSH_KEY"
  exit 1
fi

# VM definitions: name | resource group | bastion name | bastion resource group
VMS=(
  "vm-mesh-1|avnm-mesh|bas-mesh|avnm-mesh"
  "vm-mesh-2|avnm-mesh|bas-mesh|avnm-mesh"
  "vm-mesh-3|avnm-mesh|bas-mesh|avnm-mesh"
  "vm-mesh-4|avnm-mesh|bas-mesh|avnm-mesh"
  "vm-spoke1|avnm-hubnspoke|bas-hub|avnm-hubnspoke"
  "vm-spoke2|avnm-hubnspoke|bas-hub|avnm-hubnspoke"
  "vm-sec|avnm-security|bas-hub|avnm-hubnspoke"
)

echo "Select a VM to connect to:"
echo ""
for i in "${!VMS[@]}"; do
  IFS='|' read -r name rg _ _ <<< "${VMS[$i]}"
  printf "  %d) %s (%s)\n" $((i + 1)) "$name" "$rg"
done
echo ""
read -rp "Enter selection [1-${#VMS[@]}]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#VMS[@]}" ]; then
  echo "Error: Invalid selection."
  exit 1
fi

IFS='|' read -r VM_NAME VM_RG BASTION_NAME BASTION_RG <<< "${VMS[$((choice - 1))]}"

echo "Connecting to $VM_NAME via $BASTION_NAME..."

VM_ID=$(az vm show --name "$VM_NAME" --resource-group "$VM_RG" --query 'id' -o tsv)

az network bastion ssh \
  --name "$BASTION_NAME" \
  --resource-group "$BASTION_RG" \
  --target-resource-id "$VM_ID" \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key "$SSH_KEY"
