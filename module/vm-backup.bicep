// module/vm-backup.bicep

/*@description('The full Azure Resource ID of the existing Recovery Services Vault.')
param recoveryServicesVaultId string

@description('The name of the backup policy within the vault.')
param backupPolicyName string

@description('The full Azure Resource ID of the Virtual Machine to backup.')
param virtualMachineId string

// Parse the Vault Name and Resource Group from the provided Vault ID
var vaultName = last(split(recoveryServicesVaultId, '/'))
var vaultRgName = split(recoveryServicesVaultId, '/')[4]

// Parse the VM Name and Resource Group from the provided VM ID
var vmName = last(split(virtualMachineId, '/'))
var vmRgName = split(virtualMachineId, '/')[4]

var backupFabric = 'Azure'
var protectionContainerName = 'iaasvmcontainer;iaasvmcontainerv2;${vmRgName};${vmName}'
var protectedItemName = 'vm;iaasvmcontainerv2;${vmRgName};${vmName}'

// Reference the existing vault using the parsed name and scope
resource existingVault 'Microsoft.RecoveryServices/vaults@2024-04-01' existing = {
  name: vaultName
  scope: resourceGroup(vaultRgName)
}

// Enable backup protection for the virtual machine
resource vmBackupItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2024-04-01' = {
  name: '${existingVault.name}/${backupFabric}/${protectionContainerName}/${protectedItemName}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: '${existingVault.id}/backupPolicies/${backupPolicyName}'
    sourceResourceId: virtualMachineId
  }
}
*/

// module/vm-backup.bicep

@description('The full Azure Resource ID of the existing Recovery Services Vault.')
param recoveryServicesVaultId string

param location string

@description('The name of the backup policy within the vault.')
param backupPolicyName string

@description('The full Azure Resource ID of the Virtual Machine to backup.')
param virtualMachineId string

// Parse the Vault Name and Resource Group string from the Vault ID
// Format: /subscriptions/.../resourceGroups/{rgName}/providers/Microsoft.RecoveryServices/vaults/{vaultName}
var vaultName = last(split(recoveryServicesVaultId, '/'))
var vaultRgName = split(recoveryServicesVaultId, '/')[4]

// Parse the VM Name and Resource Group string from the VM ID
// Format: /subscriptions/.../resourceGroups/{rgName}/providers/Microsoft.Compute/virtualMachines/{vmName}
var vmName = last(split(virtualMachineId, '/'))
var vmRgName = split(virtualMachineId, '/')[4]

var backupFabric = 'Azure'
var protectionContainerName = 'iaasvmcontainer;iaasvmcontainerv2;${vmRgName};${vmName}'
var protectedItemName = 'vm;iaasvmcontainerv2;${vmRgName};${vmName}'

// Reference the existing vault using the properly extracted resource group string
resource existingVault 'Microsoft.RecoveryServices/vaults@2024-04-01' existing = {
  name: vaultName
  scope: resourceGroup(vaultRgName)
}

// Enable backup protection for the virtual machine
resource vmBackupItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2024-04-01' = {
  name: '${existingVault.name}/${backupFabric}/${protectionContainerName}/${protectedItemName}'
  location:location
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: '${existingVault.id}/backupPolicies/${backupPolicyName}'
    sourceResourceId: virtualMachineId
  }
}
