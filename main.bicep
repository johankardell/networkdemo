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
