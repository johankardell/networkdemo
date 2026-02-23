@description('Name of the routing configuration.')
param name string

@description('Name of the parent Virtual Network Manager.')
param networkManagerName string

@description('Network group IDs to apply the routing rules to.')
param networkGroupIds array

@description('Description of the routing configuration.')
param configDescription string = ''

@description('Routing rules to create. Each object needs: name, destinationAddress, destinationType, nextHopType, nextHopAddress (optional).')
param rules array

resource routingConfig 'Microsoft.Network/networkManagers/routingConfigurations@2024-05-01' = {
  name: '${networkManagerName}/${name}'
  properties: {
    description: configDescription
  }
}

resource ruleCollection 'Microsoft.Network/networkManagers/routingConfigurations/ruleCollections@2024-05-01' = {
  parent: routingConfig
  name: 'rc-${name}'
  properties: {
    appliesTo: [
      for groupId in networkGroupIds: {
        networkGroupId: groupId
      }
    ]
    description: 'Rule collection for ${name}'
    disableBgpRoutePropagation: 'True'
  }
}

resource routingRules 'Microsoft.Network/networkManagers/routingConfigurations/ruleCollections/rules@2024-05-01' = [
  for rule in rules: {
    parent: ruleCollection
    name: rule.name
    properties: {
      description: rule.?description ?? ''
      destination: {
        destinationAddress: rule.destinationAddress
        type: rule.destinationType
      }
      nextHop: {
        nextHopType: rule.nextHopType
        nextHopAddress: rule.?nextHopAddress ?? ''
      }
    }
  }
]

output configId string = routingConfig.id
output configName string = routingConfig.name
