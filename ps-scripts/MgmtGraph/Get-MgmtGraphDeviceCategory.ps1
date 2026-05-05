#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune device categories

.DESCRIPTION
    Retrieves properties for a specifies device category or lists all categories available in the Intune tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the device category to retrieve. If omitted, all categories are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCategory.ps1

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
            $params.Add('DeviceCategoryId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $categories = Get-MgDeviceManagementDeviceCategory @params
        
        $results = foreach ($c in $categories) {
            [PSCustomObject]@{
                DisplayName = $c.DisplayName
                Description = $c.Description
                Id          = $c.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
