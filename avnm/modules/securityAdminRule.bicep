@description('Name of the admin rule.')
param name string

@description('Full name of the parent rule collection (networkManager/config/ruleCollection).')
param ruleCollectionName string

@description('Access type for the rule.')
@allowed([
  'Allow'
  'AlwaysAllow'
  'Deny'
])
param access string

@description('Traffic direction.')
@allowed([
  'Inbound'
  'Outbound'
])
param direction string

@description('Priority of the rule (1-4096).')
@minValue(1)
@maxValue(4096)
param priority int

@description('Network protocol.')
@allowed([
  'Tcp'
  'Udp'
  'Icmp'
  'Esp'
  'Ah'
  'Any'
])
param protocol string

@description('Destination port ranges.')
param destinationPortRanges array = []

@description('Source port ranges.')
param sourcePortRanges array = []

@description('Source address prefixes.')
param sources array = []

@description('Destination address prefixes.')
param destinations array = []

@description('Description of the rule.')
param ruleDescription string = ''

resource adminRule 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/rules@2024-05-01' = {
  name: '${ruleCollectionName}/${name}'
  kind: 'Custom'
  properties: {
    access: access
    direction: direction
    priority: priority
    protocol: protocol
    description: ruleDescription
    destinationPortRanges: destinationPortRanges
    sourcePortRanges: sourcePortRanges
    sources: sources
    destinations: destinations
  }
}

output id string = adminRule.id
output name string = adminRule.name
