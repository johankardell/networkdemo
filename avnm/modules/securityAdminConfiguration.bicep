@description('Name of the security admin configuration.')
param name string

@description('Name of the parent Virtual Network Manager.')
param networkManagerName string

@description('Network group IDs to apply the configuration to.')
param networkGroupIds array

@description('Description of the security admin configuration.')
param configDescription string = ''

resource securityAdminConfig 'Microsoft.Network/networkManagers/securityAdminConfigurations@2024-05-01' = {
  name: '${networkManagerName}/${name}'
  properties: {
    description: configDescription
    applyOnNetworkIntentPolicyBasedServices: [
      'None'
    ]
  }
}

resource ruleCollection 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections@2024-05-01' = {
  parent: securityAdminConfig
  name: 'rc-${name}'
  properties: {
    appliesToGroups: [
      for groupId in networkGroupIds: {
        networkGroupId: groupId
      }
    ]
    description: 'Rule collection for ${name}'
  }
}

output configId string = securityAdminConfig.id
output configName string = securityAdminConfig.name
output ruleCollectionName string = '${securityAdminConfig.name}/${ruleCollection.name}'
