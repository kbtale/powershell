#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune device configuration profiles

.DESCRIPTION
    Retrieves properties for a specifies device configuration profile or lists all profiles currently defined in the Intune tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the device configuration profile to retrieve. If omitted, all profiles are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceConfiguration.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Identity) {
            $params.Add('DeviceConfigurationId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $configs = Get-MgDeviceManagementDeviceConfiguration @params
        
        $results = foreach ($c in $configs) {
            [PSCustomObject]@{
                DisplayName        = $c.DisplayName
                Description        = $c.Description
                Id                 = $c.Id
                Version            = $c.Version
                LastModified       = $c.LastModifiedDateTime
                Created            = $c.CreatedDateTime
                Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
