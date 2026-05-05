#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits user status for an Intune compliance policy

.DESCRIPTION
    Retrieves the per-user compliance status for a specifies device compliance policy in Microsoft Graph.

.PARAMETER PolicyId
    Specifies the ID of the device compliance policy.

.PARAMETER StatusId
    Optional. Specifies the ID of a specific user compliance status to retrieve. If omitted, all user statuses for the policy are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicyUserStatus.ps1 -PolicyId "policy-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$PolicyId,

    [string]$StatusId
)

Process {
    try {
        $params = @{
            'DeviceCompliancePolicyId' = $PolicyId
            'ErrorAction'              = 'Stop'
        }

        if ($StatusId) {
            $params.Add('DeviceComplianceUserStatusId', $StatusId)
        }
        else {
            $params.Add('All', $true)
        }

        $statuses = Get-MgDeviceManagementDeviceCompliancePolicyUserStatuses @params
        
        $results = foreach ($s in $statuses) {
            [PSCustomObject]@{
                UserDisplayName   = $s.UserDisplayName
                UserPrincipalName = $s.UserPrincipalName
                Status            = $s.Status
                LastReported      = $s.LastReportedDateTime
                DevicesCount      = $s.DevicesCount
                Id                = $s.Id
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object UserPrincipalName)
    }
    catch {
        throw
    }
}
