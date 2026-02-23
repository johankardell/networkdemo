@description('Name of the virtual network.')
param name string

@description('Azure region for the virtual network.')
param location string

@description('Address prefix for the virtual network (e.g., 10.0.0.0/16).')
param addressPrefix string

@description('Address prefix for the default subnet (e.g., 10.0.0.0/24).')
param subnetAddressPrefix string

@description('Tags to apply to the virtual network.')
param tags object = {}

@description('Optional NSG resource ID to associate with the default subnet.')
param nsgId string = ''

@description('Additional subnets beyond the default subnet.')
param additionalSubnets array = []

var defaultSubnet = [
  {
    name: 'default'
    properties: {
      addressPrefix: subnetAddressPrefix
      networkSecurityGroup: !empty(nsgId)
        ? {
            id: nsgId
          }
        : null
    }
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: concat(defaultSubnet, additionalSubnets)
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output defaultSubnetId string = virtualNetwork.properties.subnets[0].id
output subnets array = virtualNetwork.properties.subnets
