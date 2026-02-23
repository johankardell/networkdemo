@description('Name of the network group.')
param name string

@description('Name of the parent Virtual Network Manager.')
param networkManagerName string

@description('Description of the network group.')
param groupDescription string = ''

@description('Resource IDs of VNets to add as static members.')
param memberVnetIds array

resource networkGroup 'Microsoft.Network/networkManagers/networkGroups@2024-05-01' = {
  name: '${networkManagerName}/${name}'
  properties: {
    description: groupDescription
  }
}

resource staticMembers 'Microsoft.Network/networkManagers/networkGroups/staticMembers@2024-05-01' = [
  for (vnetId, i) in memberVnetIds: {
    parent: networkGroup
    name: last(split(vnetId, '/'))
    properties: {
      resourceId: vnetId
    }
  }
]

output id string = networkGroup.id
output name string = networkGroup.name
