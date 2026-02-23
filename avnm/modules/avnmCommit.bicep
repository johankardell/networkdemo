@description('Azure region for the deployment script.')
param location string

@description('Resource ID of the user-assigned managed identity.')
param userAssignedIdentityId string

@description('Name of the Virtual Network Manager.')
param networkManagerName string

@description('Resource group name where the AVNM resides.')
param resourceGroupName string

@description('Configuration IDs to commit (comma-separated if multiple).')
param configurationIds array

@description('Commit type.')
@allowed([
  'Connectivity'
  'SecurityAdmin'
])
param commitType string

@description('Target regions for the deployment.')
param targetLocations array

@description('Name of the deployment script resource.')
param deploymentScriptName string

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '12.3'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    arguments: '-networkManagerName "${networkManagerName}" -targetLocations ${join(targetLocations, ',')} -configIds ${join(configurationIds, ',')} -subscriptionId ${subscription().subscriptionId} -commitType ${commitType} -resourceGroupName ${resourceGroupName}'
    scriptContent: loadTextContent('../scripts/avnm-commit.ps1')
  }
}
