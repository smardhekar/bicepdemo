@description('VM Name')
param name string

@description('Azure Region')
param location string

@description('Tags')
param tags object = {}

@description('VM Size')
param size string

@description('Number of VM instances')
param instanceCount int = 1

@description('OS Disk SKU')
param osStorageAccountType string = 'StandardSSD_LRS'

@description('Encryption at Host')
param encryptionAtHost bool = false

@description('Image Reference')
param imageReference object

@description('Windows Configuration')
param windowsConfiguration object

@description('Admin Username')
param adminUsername string

@secure()
@description('Admin Password')
param adminPassword string

@description('Subnet Resource Id')
param subnetResourceId string

@description('Use Availability Zones')
param useAvailabilityZones bool = false

@description('Data Disks')
param dataDisks array = []

@description('Anti Malware Configuration')
param antiMalwareConfiguration object = {}

@description('Log Analytics Workspace Id')
param diagnosticLogAnalyticsWorkspaceId string = ''

resource nic 'Microsoft.Network/networkInterfaces@2025-05-01' = [
  for i in range(0, instanceCount): {
    name: '${name}${padLeft(string(i + 1), 2, '0')}-nic01'
    location: location
    tags: tags

    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'

          properties: {
            privateIPAllocationMethod: 'Dynamic'

            subnet: {
              id: subnetResourceId
            }
          }
        }
      ]
    }
  }
]

resource vm 'Microsoft.Compute/virtualMachines@2025-11-01' = [
  for i in range(0, instanceCount): {
    name: '${name}${padLeft(string(i + 1), 2, '0')}'
    location: location
    tags: tags

    zones: useAvailabilityZones ? [
      string((i % 3) + 1)
    ] : []
    properties: {
      hardwareProfile: {
        vmSize: size
      }

      securityProfile: {
        encryptionAtHost: encryptionAtHost
      }

      storageProfile: {
        imageReference: imageReference

        osDisk: {
          createOption: 'FromImage'

          managedDisk: {
            storageAccountType: osStorageAccountType
          }
        }

        dataDisks: [
          for (disk, index) in dataDisks: {
            lun: index
            createOption: 'Empty'
            diskSizeGB: disk.diskSizeGB

            caching: disk.caching

            managedDisk: {
              storageAccountType: disk.storageAccountType
            }
          }
        ]
      }

      osProfile: {
        computerName: '${name}${padLeft(string(i + 1), 2, '0')}'

        adminUsername: adminUsername

        adminPassword: adminPassword

        windowsConfiguration: windowsConfiguration
      }

      networkProfile: {
        networkInterfaces: [
          {
            id: nic[i].id
          }
        ]
      }
    }
  }
]

resource antimalwareExtension 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [
  for i in range(0, instanceCount): if (!empty(antiMalwareConfiguration)) {
    parent: vm[i]
    location:location
    name: 'IaaSAntimalware'

    properties: {
      publisher: 'Microsoft.Azure.Security'
      type: 'IaaSAntimalware'
      typeHandlerVersion: '1.5'
      autoUpgradeMinorVersion: true

      settings: antiMalwareConfiguration
    }
  }
]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for i in range(0, instanceCount): if (!empty(diagnosticLogAnalyticsWorkspaceId)) {
    scope: vm[i]

    name: 'send-to-law'

    properties: {
      workspaceId: diagnosticLogAnalyticsWorkspaceId

      metrics: [
        {
          category: 'AllMetrics'
          enabled: true
        }
      ]

      logs: [
        {
          categoryGroup: 'allLogs'
          enabled: true
        }
      ]
    }
  }
]

output virtualMachineId array = [
  for i in range(0, instanceCount): vm[i].id
]

