@description('Name of the static CIDR allocation.')
param name string

@description('Name of the parent Virtual Network Manager.')
param networkManagerName string

@description('Name of the parent IPAM pool.')
param ipamPoolName string

@description('Address prefixes to allocate (e.g., ["192.168.1.0/24"]).')
param addressPrefixes array

@description('Description of the static CIDR allocation.')
param cidrDescription string = ''

resource staticCidr 'Microsoft.Network/networkManagers/ipamPools/staticCidrs@2024-05-01' = {
  name: '${networkManagerName}/${ipamPoolName}/${name}'
  properties: {
    addressPrefixes: addressPrefixes
    description: cidrDescription
  }
}

output id string = staticCidr.id
output name string = staticCidr.name
output addressPrefixes array = addressPrefixes
