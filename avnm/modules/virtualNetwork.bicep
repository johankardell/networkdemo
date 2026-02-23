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
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
