targetScope = 'subscription'

@description('Azure region for all resources.')
param location string

@description('Tags to apply to all resources.')
param tags object = {}

// ---------------------------------------------------------------------------
// Resource Groups
// ---------------------------------------------------------------------------

resource rgAvnmManager 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'avnm-manager'
  location: location
  tags: tags
}

resource rgMesh 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'avnm-mesh'
  location: location
  tags: tags
}

resource rgHubAndSpoke 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'avnm-hubnspoke'
  location: location
  tags: tags
}

resource rgIpam 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'avnm-ipam'
  location: location
  tags: tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'avnm-security'
  location: location
  tags: tags
}

// ---------------------------------------------------------------------------
// Azure Virtual Network Manager
// ---------------------------------------------------------------------------

module avnm 'modules/virtualNetworkManager.bicep' = {
  name: 'deploy-avnm'
  scope: rgAvnmManager
  params: {
    name: 'avnm-demo'
    location: location
    scopeSubscriptionId: subscription().subscriptionId
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Managed Identity for AVNM Commit Deployments
// ---------------------------------------------------------------------------

module commitIdentity 'modules/userAssignedIdentity.bicep' = {
  name: 'deploy-avnm-commit-identity'
  scope: rgAvnmManager
  params: {
    name: 'id-avnm-commit'
    location: location
    tags: tags
  }
}

// Network Contributor role on the subscription so the identity can commit AVNM configs
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, commitIdentity.name, 'Network Contributor')
  properties: {
    principalId: commitIdentity.outputs.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
    principalType: 'ServicePrincipal'
  }
}

// ---------------------------------------------------------------------------
// Mesh VNets (avnm-mesh)
// ---------------------------------------------------------------------------

var meshVnets = [
  { name: 'vnet-1', addressPrefix: '10.0.0.0/16', subnetPrefix: '10.0.0.0/24' }
  { name: 'vnet-2', addressPrefix: '10.1.0.0/16', subnetPrefix: '10.1.0.0/24' }
  { name: 'vnet-3', addressPrefix: '10.2.0.0/16', subnetPrefix: '10.2.0.0/24' }
  { name: 'vnet-4', addressPrefix: '10.3.0.0/16', subnetPrefix: '10.3.0.0/24' }
]

module meshVnetDeployments 'modules/virtualNetwork.bicep' = [
  for vnet in meshVnets: {
    name: 'deploy-mesh-${vnet.name}'
    scope: rgMesh
    params: {
      name: vnet.name
      location: location
      addressPrefix: vnet.addressPrefix
      subnetAddressPrefix: vnet.subnetPrefix
      tags: tags
    }
  }
]

// ---------------------------------------------------------------------------
// Mesh Network Group & Connectivity Configuration
// ---------------------------------------------------------------------------

module meshNetworkGroup 'modules/networkGroup.bicep' = {
  name: 'deploy-mesh-network-group'
  scope: rgAvnmManager
  params: {
    name: 'ng-mesh'
    networkManagerName: avnm.outputs.name
    groupDescription: 'Network group for mesh-connected VNets'
    memberVnetIds: [
      for (vnet, i) in meshVnets: meshVnetDeployments[i].outputs.id
    ]
  }
}

module meshConnectivityConfig 'modules/connectivityConfiguration.bicep' = {
  name: 'deploy-mesh-connectivity-config'
  scope: rgAvnmManager
  params: {
    name: 'cc-mesh'
    networkManagerName: avnm.outputs.name
    topology: 'Mesh'
    configDescription: 'Mesh connectivity for avnm-mesh VNets'
    networkGroupIds: [
      meshNetworkGroup.outputs.id
    ]
  }
}

// ---------------------------------------------------------------------------
// Hub & Spoke VNets (avnm-hubnspoke)
// ---------------------------------------------------------------------------

var hubAndSpokeVnets = [
  { name: 'vnet-hub', addressPrefix: '10.10.0.0/16', subnetPrefix: '10.10.0.0/24' }
  { name: 'vnet-spoke1', addressPrefix: '10.11.0.0/16', subnetPrefix: '10.11.0.0/24' }
  { name: 'vnet-spoke2', addressPrefix: '10.12.0.0/16', subnetPrefix: '10.12.0.0/24' }
]

module hubSpokeVnetDeployments 'modules/virtualNetwork.bicep' = [
  for vnet in hubAndSpokeVnets: {
    name: 'deploy-hs-${vnet.name}'
    scope: rgHubAndSpoke
    params: {
      name: vnet.name
      location: location
      addressPrefix: vnet.addressPrefix
      subnetAddressPrefix: vnet.subnetPrefix
      tags: tags
    }
  }
]

// ---------------------------------------------------------------------------
// Hub & Spoke Network Group & Connectivity Configuration
// ---------------------------------------------------------------------------

module hubSpokeNetworkGroup 'modules/networkGroup.bicep' = {
  name: 'deploy-hubspoke-network-group'
  scope: rgAvnmManager
  params: {
    name: 'ng-hubspoke'
    networkManagerName: avnm.outputs.name
    groupDescription: 'Network group for hub-and-spoke VNets (spokes only)'
    memberVnetIds: [
      hubSpokeVnetDeployments[1].outputs.id // vnet-spoke1
      hubSpokeVnetDeployments[2].outputs.id // vnet-spoke2
    ]
  }
}

module hubSpokeConnectivityConfig 'modules/connectivityConfiguration.bicep' = {
  name: 'deploy-hubspoke-connectivity-config'
  scope: rgAvnmManager
  params: {
    name: 'cc-hubspoke'
    networkManagerName: avnm.outputs.name
    topology: 'HubAndSpoke'
    configDescription: 'Hub-and-spoke connectivity for avnm-hubnspoke VNets'
    hubVnetId: hubSpokeVnetDeployments[0].outputs.id // vnet-hub
    networkGroupIds: [
      hubSpokeNetworkGroup.outputs.id
    ]
  }
}

// ---------------------------------------------------------------------------
// IPAM Pool (avnm-manager)
// ---------------------------------------------------------------------------

module ipamPool 'modules/ipamPool.bicep' = {
  name: 'deploy-ipam-pool'
  scope: rgAvnmManager
  params: {
    name: 'ipam-pool-demo'
    location: location
    networkManagerName: avnm.outputs.name
    addressPrefixes: [
      '192.168.0.0/16'
    ]
    displayName: 'Demo IPAM Pool'
    poolDescription: 'Root IPAM pool for address management demo'
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// IPAM Static CIDRs & VNets (avnm-ipam)
// ---------------------------------------------------------------------------

var ipamVnets = [
  { name: 'vnet-ipam-1', addressPrefix: '192.168.1.0/24', subnetPrefix: '192.168.1.0/25' }
  { name: 'vnet-ipam-2', addressPrefix: '192.168.2.0/24', subnetPrefix: '192.168.2.0/25' }
  { name: 'vnet-ipam-3', addressPrefix: '192.168.3.0/24', subnetPrefix: '192.168.3.0/25' }
]

module ipamStaticCidrs 'modules/staticCidr.bicep' = [
  for vnet in ipamVnets: {
    name: 'deploy-cidr-${vnet.name}'
    scope: rgAvnmManager
    params: {
      name: vnet.name
      ipamPoolName: ipamPool.outputs.name
      addressPrefixes: [
        vnet.addressPrefix
      ]
      cidrDescription: 'Static CIDR allocation for ${vnet.name}'
    }
  }
]

module ipamVnetDeployments 'modules/virtualNetwork.bicep' = [
  for (vnet, i) in ipamVnets: {
    name: 'deploy-ipam-${vnet.name}'
    scope: rgIpam
    params: {
      name: vnet.name
      location: location
      addressPrefix: vnet.addressPrefix
      subnetAddressPrefix: vnet.subnetPrefix
      tags: tags
    }
    dependsOn: [
      ipamStaticCidrs[i]
    ]
  }
]

// ---------------------------------------------------------------------------
// Security VNet & NSG (avnm-security)
// ---------------------------------------------------------------------------

module securityNsg 'modules/networkSecurityGroup.bicep' = {
  name: 'deploy-nsg-security'
  scope: rgSecurity
  params: {
    name: 'nsg-security'
    location: location
    tags: tags
  }
}

module securityVnet 'modules/virtualNetwork.bicep' = {
  name: 'deploy-vnet-sec'
  scope: rgSecurity
  params: {
    name: 'vnet-sec'
    location: location
    addressPrefix: '10.20.0.0/16'
    subnetAddressPrefix: '10.20.0.0/24'
    nsgId: securityNsg.outputs.id
    tags: tags
  }
}

module securityNetworkGroup 'modules/networkGroup.bicep' = {
  name: 'deploy-security-network-group'
  scope: rgAvnmManager
  params: {
    name: 'ng-security'
    networkManagerName: avnm.outputs.name
    groupDescription: 'Network group for security admin configuration'
    memberVnetIds: [
      securityVnet.outputs.id
    ]
  }
}

// ---------------------------------------------------------------------------
// Security Admin Configuration & Rule
// ---------------------------------------------------------------------------

module securityAdminConfig 'modules/securityAdminConfiguration.bicep' = {
  name: 'deploy-security-admin-config'
  scope: rgAvnmManager
  params: {
    name: 'sac-security'
    networkManagerName: avnm.outputs.name
    configDescription: 'Security admin configuration for ng-security'
    networkGroupIds: [
      securityNetworkGroup.outputs.id
    ]
  }
}

module allowPort9090Rule 'modules/securityAdminRule.bicep' = {
  name: 'deploy-allow-port-9090-rule'
  scope: rgAvnmManager
  params: {
    name: 'always-allow-9090'
    ruleCollectionName: securityAdminConfig.outputs.ruleCollectionName
    access: 'AlwaysAllow'
    direction: 'Inbound'
    priority: 100
    protocol: 'Tcp'
    ruleDescription: 'Always allow inbound TCP port 9090'
    destinationPortRanges: [
      '9090'
    ]
    sources: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinations: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Commit AVNM Configurations
// ---------------------------------------------------------------------------

module commitConnectivity 'modules/avnmCommit.bicep' = {
  name: 'commit-connectivity-configs'
  scope: rgAvnmManager
  params: {
    location: location
    userAssignedIdentityId: commitIdentity.outputs.id
    networkManagerName: 'avnm-demo'
    resourceGroupName: rgAvnmManager.name
    commitType: 'Connectivity'
    targetLocations: [
      location
    ]
    configurationIds: [
      meshConnectivityConfig.outputs.id
      hubSpokeConnectivityConfig.outputs.id
    ]
    deploymentScriptName: 'ds-commit-connectivity'
  }
  dependsOn: [
    roleAssignment
  ]
}

module commitSecurityAdmin 'modules/avnmCommit.bicep' = {
  name: 'commit-security-admin-config'
  scope: rgAvnmManager
  params: {
    location: location
    userAssignedIdentityId: commitIdentity.outputs.id
    networkManagerName: 'avnm-demo'
    resourceGroupName: rgAvnmManager.name
    commitType: 'SecurityAdmin'
    targetLocations: [
      location
    ]
    configurationIds: [
      securityAdminConfig.outputs.configId
    ]
    deploymentScriptName: 'ds-commit-securityadmin'
  }
  dependsOn: [
    roleAssignment
    allowPort9090Rule
  ]
}
