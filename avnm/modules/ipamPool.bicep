@description('Name of the IPAM pool.')
param name string

@description('Azure region for the IPAM pool.')
param location string

@description('Name of the parent Virtual Network Manager.')
param networkManagerName string

@description('Address prefixes for the pool (e.g., ["192.168.0.0/16"]).')
param addressPrefixes array

@description('Display name for the pool.')
param displayName string = ''

@description('Description of the pool.')
param poolDescription string = ''

@description('Tags to apply to the IPAM pool.')
param tags object = {}

resource ipamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: '${networkManagerName}/${name}'
  location: location
  tags: tags
  properties: {
    addressPrefixes: addressPrefixes
    displayName: displayName
    description: poolDescription
  }
}

output id string = ipamPool.id
output name string = ipamPool.name
