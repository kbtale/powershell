#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits detected applications on managed devices

.DESCRIPTION
    Retrieves properties for a specifies detected application or lists all applications discovered across managed devices in the tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the detected application to retrieve. If omitted, all detected apps are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDetectedApp.ps1

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
            $params.Add('DetectedAppId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $apps = Get-MgDeviceManagementDetectedApp @params
        
        $results = foreach ($a in $apps) {
            [PSCustomObject]@{
                DisplayName  = $a.DisplayName
                Version      = $a.Version
                SizeInBytes  = $a.SizeInBytes
                DeviceCount  = $a.DeviceCount
                Id           = $a.Id
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
