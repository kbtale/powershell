#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits user status overview for an Intune compliance policy

.DESCRIPTION
    Retrieves the aggregate user status counts (Success, Failure, etc.) for a specifies device compliance policy in Microsoft Graph.

.PARAMETER Identity
    Specifies the ID of the device compliance policy.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicyUserStatusOverview.ps1 -Identity "policy-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $overview = Get-MgDeviceManagementDeviceCompliancePolicyUserStatusOverview -DeviceCompliancePolicyId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            PolicyId             = $Identity
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
