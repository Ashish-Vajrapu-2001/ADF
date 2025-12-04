@description('Parameters for the storage account configuration.')
param storageAccountName string
param resourceGroupName string
param softDeleteRetentionDays int = 8
param containerVersioningEnabled bool = true // Enabling blob versioning

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
  scope: resourceGroup(resourceGroupName)
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: softDeleteRetentionDays
    }
    isVersioningEnabled: containerVersioningEnabled
  }
}

output storageAccountId string = storageAccount.id
output blobServicesId string = blobServices.id
