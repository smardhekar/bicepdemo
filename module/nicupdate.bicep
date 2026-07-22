/*targetScope = 'resourceGroup'

param nicName string = 'gidaemeprod01-nic01'
param subnetId string = '/subscriptions/f3dd0da4-7099-4d1a-a008-2c8d73c9bff9/resourceGroups/gid-aue-shd-platform-rg01/providers/Microsoft.Network/virtualNetworks/gid-aue-shd-platform-vnet01/subnets/PlatformSubnet'

param dnsServers array = [
  '10.10.0.4'
  '10.10.0.5'
]

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: nicName
  location: resourceGroup().location
    properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
        }
      }
    ]

    dnsSettings: {
      dnsServers: dnsServers
    }
  }
}*/
