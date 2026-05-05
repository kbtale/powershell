#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Lists Intune device categories for selection

.DESCRIPTION
    Retrieves all device categories from Microsoft Graph and returns them as a simplified list of Name/ID pairs, optimized for UI selection and reporting.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCategoryDetail.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $categories = Get-MgDeviceManagementDeviceCategory -All -ErrorAction Stop
        
        $results = foreach ($c in $categories) {
            [PSCustomObject]@{
                DisplayName = $c.DisplayName
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
