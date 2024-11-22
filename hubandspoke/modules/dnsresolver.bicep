// https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-get-started-bicep?tabs=CLI#review-the-bicep-file

param name string
param location string
param hubvnetid string
param inboundsubnetid string
param outboundsubnetid string

resource dnsresolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: name
  location: location
  properties: {
    virtualNetwork: {
      id: hubvnetid
    }
  }
}

resource inEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: dnsresolver
  name: 'inboundendpoint'
  location: location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Dynamic'
        subnet: {
          id: inboundsubnetid
        }
      }
    ]
  }
}

resource outEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: dnsresolver
  name: 'outboundendpoint'
  location: location
  properties: {
    subnet: {
      id: outboundsubnetid
    }
  }
}
