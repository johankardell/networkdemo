@description('Name of the virtual network.')
param name string

@description('Azure region for the virtual network.')
param location string

@description('Address prefix for the virtual network (e.g., 10.0.0.0/16). Ignored when ipamPoolId is set.')
param addressPrefix string = ''

@description('Address prefix for the default subnet (e.g., 10.0.0.0/24). Ignored when ipamPoolId is set.')
param subnetAddressPrefix string = ''

@description('Tags to apply to the virtual network.')
param tags object = {}

@description('Optional NSG resource ID to associate with the default subnet.')
param nsgId string = ''

@description('Additional subnets beyond the default subnet.')
param additionalSubnets array = []

@description('Optional IPAM pool resource ID. When set, addresses are allocated from the pool instead of using static prefixes.')
param ipamPoolId string = ''

@description('Number of IP addresses to allocate from the IPAM pool for the VNet address space.')
param vnetIpAddressCount string = '256'

@description('Number of IP addresses to allocate from the IPAM pool for the default subnet.')
param subnetIpAddressCount string = '128'

var nsgProperty = !empty(nsgId) ? { networkSecurityGroup: { id: nsgId } } : {}

var staticSubnetProps = union({ addressPrefix: subnetAddressPrefix }, nsgProperty)

var ipamSubnetProps = union({
  ipamPoolPrefixAllocations: [
    {
      pool: { id: ipamPoolId }
      numberOfIpAddresses: subnetIpAddressCount
    }
  ]
}, nsgProperty)

var defaultSubnet = [
  {
    name: 'default'
    properties: !empty(ipamPoolId) ? ipamSubnetProps : staticSubnetProps
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: !empty(ipamPoolId) ? {
      ipamPoolPrefixAllocations: [
        {
          pool: { id: ipamPoolId }
          numberOfIpAddresses: vnetIpAddressCount
        }
      ]
    } : {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: concat(defaultSubnet, additionalSubnets)
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output defaultSubnetId string = virtualNetwork.properties.subnets[0].id
output subnets array = virtualNetwork.properties.subnets
