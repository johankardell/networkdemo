param name string
param vnetname string
param vnetid string

resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
}

resource linktovnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: zone
  name: vnetname
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetid
    }
  }
}
