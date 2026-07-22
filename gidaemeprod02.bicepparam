using 'main.bicep'

param resourceGroupName = 'gid-aue-shd-manageengine-rg01'
param location = 'australiaeast'

param vmName = 'gidaemeprod' // the 01, 02... suffix will be added by the module
param vmSubnetId = '/subscriptions/f3dd0da4-7099-4d1a-a008-2c8d73c9bff9/resourceGroups/gid-aue-shd-platform-rg01/providers/Microsoft.Network/virtualNetworks/gid-aue-shd-platform-vnet01/subnets/PlatformSubnet'

param keyVaultName = 'gid-aue-shd-platfrm-kv00'
param keyVaultResourceGroupName = 'gid-aue-shd-security-rg01'

param recoveryServicesVaultName = 'gid-aue-shd-platform-rsv01'
param recoveryServicesVaultResourceGroupName = 'gid-aue-shd-platform-rg01'
