#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Graph devices

.DESCRIPTION
    Retrieves properties for a specifies device or lists all devices in the Microsoft Graph tenant, including compliance and OS details.

.PARAMETER Identity
    Optional. Specifies the ID of the device to retrieve. If omitted, all devices are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDevice.ps1

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
            $params.Add('DeviceId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $devices = Get-MgDevice @params
        
        $results = foreach ($d in $devices) {
            [PSCustomObject]@{
                DisplayName     = $d.DisplayName
                Id              = $d.Id
                DeviceId        = $d.DeviceId
                OS              = $d.OperatingSystem
                OSVersion       = $d.OperatingSystemVersion
                AccountEnabled  = $d.AccountEnabled
                IsCompliant     = $d.IsCompliant
                TrustType       = $d.TrustType
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
