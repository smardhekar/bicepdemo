targetScope = 'resourceGroup'

@description('Name of the secret to create')
param name string

@description('Existing Key Vault name')
param keyVaultName string

@secure()
@description('Secret value')
param value string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent:keyVault
  name: name
  properties: {
    value: value
  }
}
output secretId string = secret.id
output secretName string = name
