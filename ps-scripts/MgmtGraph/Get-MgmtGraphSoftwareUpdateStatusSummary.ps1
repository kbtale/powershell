#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits software update status summary

.DESCRIPTION
    Retrieves a high-level summary of software update compliance across the Intune-managed fleet from Microsoft Graph.

.EXAMPLE
    PS> ./Get-MgmtGraphSoftwareUpdateStatusSummary.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $summary = Get-MgDeviceManagementSoftwareUpdateStatusSummary -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            CompliantDeviceCount     = $summary.CompliantDeviceCount
            NonCompliantDeviceCount  = $summary.NonCompliantDeviceCount
            RemediatedDeviceCount    = $summary.RemediatedDeviceCount
            ErrorDeviceCount         = $summary.ErrorDeviceCount
            UnknownDeviceCount       = $summary.UnknownDeviceCount
            ConflictDeviceCount      = $summary.ConflictDeviceCount
            NotApplicableDeviceCount = $summary.NotApplicableDeviceCount
            Timestamp                = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
