#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune device compliance policy assignments

.DESCRIPTION
    Retrieves the assignments for a specifies device compliance policy, showing which groups or users are targeted for enforcement.

.PARAMETER PolicyId
    Specifies the ID of the device compliance policy.

.PARAMETER AssignmentId
    Optional. Specifies the ID of a specific assignment to retrieve. If omitted, all assignments for the policy are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicyAssignment.ps1 -PolicyId "policy-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$PolicyId,

    [string]$AssignmentId
)

Process {
    try {
        $params = @{
            'DeviceCompliancePolicyId' = $PolicyId
            'ErrorAction'              = 'Stop'
        }

        if ($AssignmentId) {
            $params.Add('AssignmentId', $AssignmentId)
        }
        else {
            $params.Add('All', $true)
        }

        $assignments = Get-MgDeviceManagementDeviceCompliancePolicyAssignment @params
        
        $results = foreach ($a in $assignments) {
            [PSCustomObject]@{
                PolicyId     = $PolicyId
                AssignmentId = $a.Id
                Target       = $a.Target.OdataType
                GroupId      = $a.Target.GroupId
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
