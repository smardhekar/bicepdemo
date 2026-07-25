targetScope = 'subscription'
param resourceGroupName string
@allowed([ 'australiaeast', 'australiasoutheast' ])
param location string
param tags object = {
  OpCo: 'GroupIdOne'
  Environment: 'Production'
  BusinessService: 'ME Analytics Plus'
  Criticality: 'Medium'
  BusinessOwner: 'IT'
  TechnicalOwner: 'IT'
  MaintenanceWindow: 'N/A'
  DataClassification: 'N/A'
}

param vmName string
@secure()
param vmAdminPassword string = '${toUpper(uniqueString(vmName))}-${newGuid()}' // Autogenerates a password and stores it in a key vault
param vmAdminUsername string = 'azmeadmin'
param vmSubnetId string

@allowed([ 'Standard', 'Enterprise', 'CriticalEnterprise' ])
param backupPolicyName string = 'Standard'
param recoveryServicesVaultResourceGroupName string
param recoveryServicesVaultName string // Backups can only be enabled on a Recovery Services Vault in the same region as the VM

param keyVaultResourceGroupName string
param keyVaultName string
//param diagnosticLogAnalyticsWorkspaceId string = location == 'australiaeast' ? '/subscriptions/fd68adc8-44c3-4f5f-b7da-b639455e8800/resourceGroups/gid-aue-shd-management-rg01/providers/Microsoft.OperationalInsights/workspaces/gid-aue-shd-management-log01' : '/subscriptions/fd68adc8-44c3-4f5f-b7da-b639455e8800/resourceGroups/gid-ase-shd-management-rg01/providers/Microsoft.OperationalInsights/workspaces/gid-ase-shd-management-log01'

// Create Resource Group for Manage Engine (creates if it doesn't exist)
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module windowsVM 'module/virtual-machines.bicep' = {
  scope: rg
  name: vmName

  params: {
    name: vmName
    location: location
    tags: tags
    size: 'Standard_D2ds_v5'
    instanceCount: 1
    osStorageAccountType: 'Premium_LRS'
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
        }
    windowsConfiguration: {
      enableAutomaticUpdates: true
      provisionVMAgent: true
      timeZone: 'AUS Eastern Standard Time'
    }
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    subnetResourceId: vmSubnetId
    dataDisks: [
      {
        storageAccountType: 'Premium_LRS'
        diskSizeGB: 256
        caching: 'None'
      }
    ]
    antiMalwareConfiguration: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: 'true'
      ScheduledScanSettings: {
        isEnabled: 'true'
        scanType: 'Quick'
        day: '7'
        time: '120'
      }
    }
    //diagnosticLogAnalyticsWorkspaceId: diagnosticLogAnalyticsWorkspaceId
     }
}








// Create a backup policy
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2024-10-01' existing = {
  scope: resourceGroup(recoveryServicesVaultResourceGroupName)
  name: recoveryServicesVaultName
}
module vmBackup 'module/vm-backup.bicep' = {
  scope: resourceGroup(recoveryServicesVaultResourceGroupName)
  name: '${vmName}-backup'

  params: {
    backupPolicyName: backupPolicyName
    recoveryServicesVaultId: recoveryServicesVault.id
    virtualMachineId: windowsVM.outputs.virtualMachineId[0]
    location:location
  }
}

// Pushes the generated password to the specified key vault
module keyVaultSecret 'module/vaults-secrets.bicep' = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: 'key-vault-secret-${vmName}'
  dependsOn: [ windowsVM ]

  params: {
    name: toLower('${vmName}-adminpassword')
    keyVaultName: keyVaultName
    value: vmAdminPassword
  }
}




