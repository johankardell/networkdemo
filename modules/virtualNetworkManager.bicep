@description('Name of the Virtual Network Manager.')
param name string

@description('Azure region for the Virtual Network Manager.')
param location string

@description('Subscription ID to scope the Virtual Network Manager to.')
param scopeSubscriptionId string

@description('Tags to apply to the Virtual Network Manager.')
param tags object = {}

resource networkManager 'Microsoft.Network/networkManagers@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    networkManagerScopes: {
      subscriptions: [
        '/subscriptions/${scopeSubscriptionId}'
      ]
    }
    networkManagerScopeAccesses: [
      'Connectivity'
      'SecurityAdmin'
    ]
  }
}

output id string = networkManager.id
output name string = networkManager.name
