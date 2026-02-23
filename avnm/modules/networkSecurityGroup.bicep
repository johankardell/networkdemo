@description('Name of the network security group.')
param name string

@description('Azure region for the network security group.')
param location string

@description('Tags to apply to the network security group.')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

output id string = nsg.id
output name string = nsg.name
