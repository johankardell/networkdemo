targetScope = 'subscription'

param location string

param hubRGName string
param spokeRGName string
param onpremRGName string

param hubVnetName string
param hubVnetAddressPrefix string
param azurebastionsubnetprefix string
param azurefirewallsubnetprefix string
param dnsresolverinboundsubnetprefix string
param dnsresolveroutboundsubnetprefix string
param bastionName string
param dnsresolvername string

param spokeVnetName string
param spokeVnetAddressPrefix string
param storageaccountname string

param onpremVnetName string
param onpremVnetAddressPrefix string

resource hubRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: hubRGName
  location: location
}

resource spokeRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: spokeRGName
  location: location
}

resource onpremRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: onpremRGName
  location: location
}


/////////////// Hub //////////////////////

module hubVnet 'modules/hubvnet.bicep' = {
  scope: hubRG
  name: hubVnetName
  params: {
    addressPrefix: hubVnetAddressPrefix
    location: location
    name: hubVnetName
    azurebastionsubnetprefix: azurebastionsubnetprefix
    azurefirewallsubnetprefix: azurefirewallsubnetprefix
    dnsresolverinboundsubnetprefix: dnsresolverinboundsubnetprefix
    dnsresolveroutboundsubnetprefix: dnsresolveroutboundsubnetprefix
  }
}

module bastion 'modules/bastion.bicep' = {
  scope: hubRG
  name: bastionName
  params: {
    location: location
    name: bastionName
    subnetid: hubVnet.outputs.bastionsubnetid
  }
}

module dnsresolver 'modules/dnsresolver.bicep' = {
  scope: hubRG
  name: dnsresolvername
  params: {
    location: location
    name: dnsresolvername
    hubvnetid: hubVnet.outputs.vnetid
    inboundsubnetid: hubVnet.outputs.inboundsubnetid
    outboundsubnetid: hubVnet.outputs.outboundsubnetid
  }
}

module storagednszone 'modules/dnszone.bicep' = {
  scope: hubRG
  name: 'storagednszone'
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    vnetid: hubVnet.outputs.vnetid
     vnetname: hubVnetName
  }
}

/////////////// Spoke //////////////////////

module spokeVnet 'modules/spokevnet.bicep' = {
  scope: spokeRG
  name: spokeVnetName
  params: {
    addressPrefix: spokeVnetAddressPrefix
    location: location
    name: spokeVnetName
  }
}

module storageAccount 'modules/storageaccount.bicep' = {
  scope: spokeRG
  name: storageaccountname
  params: {
    location: location
    name: storageaccountname
  }
}

////////////// Onprem //////////////////////

module onpremVnet 'modules/onpremvnet.bicep' = {
  scope: onpremRG
  name: onpremVnetName
  params: {
    addressPrefix: onpremVnetAddressPrefix
    location: location
    name: onpremVnetName
  }
}
