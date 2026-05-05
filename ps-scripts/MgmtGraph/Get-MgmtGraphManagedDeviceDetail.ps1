#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Lists Intune managed devices for selection

.DESCRIPTION
    Retrieves all managed devices from Microsoft Graph and returns them as a simplified list of Name/ID pairs, optimized for UI selection and reporting.

.EXAMPLE
    PS> ./Get-MgmtGraphManagedDeviceDetail.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $devices = Get-MgDeviceManagementManagedDevice -All -ErrorAction Stop
        
        $results = foreach ($d in $devices) {
            [PSCustomObject]@{
                DeviceName = $d.DeviceName
                Id         = $d.Id
                UserPrincipalName = $d.UserPrincipalName
                Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DeviceName)
    }
    catch {
        throw
    }
}
