using 'main.bicep'

param location = 'swedencentral'
param hubRGName = 'rg-networkdemo-hub'
param spokeRGName = 'rg-networkdemo-spoke'
param onpremRGName = 'rg-networkdemo-onprem'

param hubVnetName = 'vnet-hub'
param hubVnetAddressPrefix = '10.0.0.0/20'
param azurebastionsubnetprefix = '10.0.1.0/25'
param azurefirewallsubnetprefix = '10.0.0.0/24'
param dnsresolverinboundsubnetprefix = '10.0.2.0/25'
param dnsresolveroutboundsubnetprefix = '10.0.2.128/25'
param bastionName = 'bastion'
param dnsresolvername = 'dnsresolver'

param spokeVnetName = 'vnet-spoke'
param spokeVnetAddressPrefix = '10.0.10.0/24'
param storageaccountname = 'stnetworkdemojk2024'

param onpremVnetName = 'vnet-onprem'
param onpremVnetAddressPrefix = '172.16.0.0/24'
