@description('Main Bicep template for deploying core data platform infrastructure.')
param resourceGroupName string
param storageAccountName string
param location string = resourceGroup().location
param dataFactoryName string
param softDeleteRetentionDays int = 8
param containerVersioningEnabled bool = true

// Module to configure the existing ADLS Gen2 storage account for reliability.
// This ensures soft delete and versioning are enabled on the blob service.
module storageConfig 'storage-account.bicep' = {
  name: 'storage-blob-config-${storageAccountName}'
  params: {
    storageAccountName: storageAccountName
    resourceGroupName: resourceGroupName
    softDeleteRetentionDays: softDeleteRetentionDays
    containerVersioningEnabled: containerVersioningEnabled
  }
}

// Data Factory Resource Definition (minimal, assuming existing or for initial creation)
// The actual ADF artifacts (pipelines, datasets, linked services) are deployed via Git integration,
// so this primarily ensures the ADF instance exists with managed identity enabled.
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned' // Enable System Managed Identity for ADF
  }
  properties: {
    publicNetworkAccess: 'Enabled' // Or 'Disabled' with private endpoints for higher security
    repoConfiguration: { // Placeholder for Git config, actual config is done in portal
      type: 'FactoryGitHubConfiguration'
      accountName: '<YourGitHubAccount>'
      repositoryName: '<YourRepoName>'
      collaborationBranch: '<YourCollaborationBranch>'
      rootFolder: '/'
      lastCommitId: ''
      projectName: '<YourProjectName>'
    }
  }
  tags: {
    environment: 'dev' // Example tag
    project: 'CLV_Analytics'
    costCenter: 'DataPlatform'
  }
}

output dataFactoryId string = dataFactory.id
output dataFactoryPrincipalId string = dataFactory.identity.principalId
