param name string
param location string

param addressPrefix string
param azurefirewallsubnetprefix string
param azurebastionsubnetprefix string
param dnsresolverinboundsubnetprefix string
param dnsresolveroutboundsubnetprefix string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: azurefirewallsubnetprefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: azurebastionsubnetprefix
        }
      }
      {
        name: 'dnsresolverinbound'
        properties: {
          addressPrefix: dnsresolverinboundsubnetprefix
          delegations: [
            {
              name: 'dnsresolverdelegation'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'dnsresolveroutbound'
        properties: {
          addressPrefix: dnsresolveroutboundsubnetprefix
          delegations: [
            {
              name: 'dnsresolverdelegation'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
    ]
  }
}

output bastionsubnetid string = vnet.properties.subnets[1].id
output vnetid string = vnet.id
output inboundsubnetid string = vnet.properties.subnets[2].id
output outboundsubnetid string = vnet.properties.subnets[3].id
