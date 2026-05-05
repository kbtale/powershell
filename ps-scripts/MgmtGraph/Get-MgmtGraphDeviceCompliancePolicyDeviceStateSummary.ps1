#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits compliance policy device state summary

.DESCRIPTION
    Retrieves a high-level summary of device compliance states across all policies in the Intune tenant from Microsoft Graph.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicyDeviceStateSummary.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $summary = Get-MgDeviceManagementDeviceCompliancePolicyDeviceStateSummary -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            CompliantDeviceCount             = $summary.CompliantDeviceCount
            ConfigManagerClientHealthCount   = $summary.ConfigManagerClientHealthCount
            ConflictDeviceCount              = $summary.ConflictDeviceCount
            ErrorDeviceCount                 = $summary.ErrorDeviceCount
            InGracePeriodDeviceCount         = $summary.InGracePeriodDeviceCount
            NonCompliantDeviceCount          = $summary.NonCompliantDeviceCount
            NotApplicableDeviceCount         = $summary.NotApplicableDeviceCount
            RemediatedDeviceCount            = $summary.RemediatedDeviceCount
            UnknownDeviceCount               = $summary.UnknownDeviceCount
            Timestamp                        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
