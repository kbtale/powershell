#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits configuration profile device state summary

.DESCRIPTION
    Retrieves a high-level summary of device configuration deployment states across all profiles in the Intune tenant from Microsoft Graph.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceConfigurationDeviceStateSummary.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $summary = Get-MgDeviceManagementDeviceConfigurationDeviceStateSummary -ErrorAction Stop
        
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
