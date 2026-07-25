targetScope = 'resourceGroup'

param nicName string = 'gidaemeprod01-nic'
param dnsServers array = [
  '10.10.0.4'
  '10.10.0.5'
]

@description('User Assigned Managed Identity Resource ID')
param userAssignedIdentityId string

resource updateNicDns 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'update-existing-nic-dns'
  location: resourceGroup().location
  kind: 'AzurePowerShell'

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }

  properties: {
    azPowerShellVersion: '14.0'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnSuccess'

    scriptContent: '''
      $resourceGroupName = "${resourceGroup().name}"
      $nicName = "${nicName}"

      $dnsServers = @(
        ${join([for dns in dnsServers: "'${dns}'"], ',')}
      )

      Write-Output "Getting NIC: $nicName"

      $nic = Get-AzNetworkInterface
        -ResourceGroupName $resourceGroupName
        -Name ${nicName}

      $nic.DnsSettings.DnsServers = $dnsServers

      $result = Set-AzNetworkInterface -NetworkInterface $nic

      Write-Output "DNS Servers Updated Successfully"
      Write-Output ($result.DnsSettings.DnsServers -join ',')
    '''
  }
}
