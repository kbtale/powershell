#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Lists Intune device compliance policies for selection

.DESCRIPTION
    Retrieves all device compliance policies from Microsoft Graph and returns them as a simplified list of Name/ID pairs, optimized for UI selection and reporting.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicyDetail.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $policies = Get-MgDeviceManagementDeviceCompliancePolicy -All -ErrorAction Stop
        
        $results = foreach ($p in $policies) {
            [PSCustomObject]@{
                DisplayName = $p.DisplayName
                Id          = $p.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
