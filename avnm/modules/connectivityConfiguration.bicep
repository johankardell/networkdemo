@description('Name of the connectivity configuration.')
param name string

@description('Name of the parent Virtual Network Manager.')
param networkManagerName string

@description('Connectivity topology.')
@allowed([
  'Mesh'
  'HubAndSpoke'
])
param topology string

@description('Network group IDs to include in this configuration.')
param networkGroupIds array

@description('Description of the connectivity configuration.')
param configDescription string = ''

resource connectivityConfig 'Microsoft.Network/networkManagers/connectivityConfigurations@2024-05-01' = {
  name: '${networkManagerName}/${name}'
  properties: {
    description: configDescription
    connectivityTopology: topology
    appliesToGroups: [
      for groupId in networkGroupIds: {
        networkGroupId: groupId
        groupConnectivity: 'DirectlyConnected'
        useHubGateway: 'False'
        isGlobal: 'False'
      }
    ]
    deleteExistingPeering: 'True'
    isGlobal: 'False'
  }
}

output id string = connectivityConfig.id
output name string = connectivityConfig.name
