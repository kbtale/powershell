#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Adds a group to a lifecycle policy

.DESCRIPTION
    Associates a specifies group with a group lifecycle (expiration) policy in Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER GroupLifecyclePolicyId
    Optional. The unique identifier of the lifecycle policy. If not specifies, the script will automatically discover and use the first available policy in the tenant.

.EXAMPLE
    PS> ./Add-MgmtGraphGroupToLifecyclePolicy.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Add-MgmtGraphGroupToLifecyclePolicy.ps1 -GroupId "group-id-123" -GroupLifecyclePolicyId "policy-id-456"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [string]$GroupLifecyclePolicyId
)

Process {
    try {
        $policyId = $GroupLifecyclePolicyId
        if (-not $policyId) {
            $policies = Get-MgGroupLifecyclePolicy -ErrorAction Stop
            if (-not $policies) {
                throw "No active group lifecycle policies found in the tenant."
            }
            $policyId = $policies[0].Id
        }

        $params = @{
            'GroupId'                 = $GroupId
            'GroupLifecyclePolicyId' = $policyId
            'ErrorAction'             = 'Stop'
        }

        $success = Add-MgGroupToLifecyclePolicy @params
        
        $result = [PSCustomObject]@{
            GroupId                = $GroupId
            GroupLifecyclePolicyId = $policyId
            Added                  = $true
            Timestamp              = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
