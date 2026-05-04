#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Lists all ActiveSync Mailbox Policies

.DESCRIPTION
    Retrieves an inventory of all ActiveSync Mailbox Policies configured in the Exchange organization.

.PARAMETER Identity
    Optional. Specifies the Identity of a specific policy to retrieve.

.EXAMPLE
    PS> ./Get-ExchangeActiveSyncPolicy.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }
        if ($Identity) { $params.Add('Identity', $Identity) }

        $policies = Get-ActiveSyncMailboxPolicy @params

        $results = foreach ($p in $policies) {
            [PSCustomObject]@{
                Name                        = $p.Name
                IsDefault                   = $p.IsDefault
                AllowNonProvisionableDevices = $p.AllowNonProvisionableDevices
                DevicePasswordEnabled       = $p.DevicePasswordEnabled
                AlphanumericDevicePasswordRequired = $p.AlphanumericDevicePasswordRequired
                DistinguishedName           = $p.DistinguishedName
                LastModified                = $p.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
