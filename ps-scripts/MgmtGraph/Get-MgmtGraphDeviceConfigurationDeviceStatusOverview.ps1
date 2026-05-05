#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits status overview for an Intune configuration profile

.DESCRIPTION
    Retrieves the aggregate device status counts (Success, Failure, etc.) for a specifies device configuration profile in Microsoft Graph.

.PARAMETER Identity
    Specifies the ID of the device configuration profile.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceConfigurationDeviceStatusOverview.ps1 -Identity "config-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $overview = Get-MgDeviceManagementDeviceConfigurationDeviceStatusOverview -DeviceConfigurationId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            ConfigurationId      = $Identity
            SuccessCount         = $overview.SuccessCount
            NotApplicableCount   = $overview.NotApplicableCount
            PendingCount         = $overview.PendingCount
            ErrorCount           = $overview.ErrorCount
            FailedCount          = $overview.FailedCount
            ConflictCount        = $overview.ConflictCount
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
