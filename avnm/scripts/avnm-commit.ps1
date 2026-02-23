param (
  [parameter(mandatory=$true)][string]$subscriptionId,
  [parameter(mandatory=$true)][string]$networkManagerName,
  [parameter(mandatory=$true)][string[]]$configIds,
  [parameter(mandatory=$true)][string[]]$targetLocations,
  [parameter(mandatory=$true)][ValidateSet('Connectivity','SecurityAdmin')][string]$commitType,
  [parameter(mandatory=$true)][string]$resourceGroupName
)

$null = Login-AzAccount -Identity -Subscription $subscriptionId

[System.Collections.Generic.List[string]]$configIdList = @()
$configIdList.addRange($configIds)
[System.Collections.Generic.List[string]]$targetLocationList = @()
$targetLocationList.addRange($targetLocations)

$deployment = @{
  Name              = $networkManagerName
  ResourceGroupName = $resourceGroupName
  ConfigurationId   = $configIdList
  TargetLocation    = $targetLocationList
  CommitType        = $commitType
}

try {
  Deploy-AzNetworkManagerCommit @deployment -ErrorAction Stop
}
catch {
  Write-Error "Deployment failed with error: $_"
  throw "Deployment failed with error: $_"
}
