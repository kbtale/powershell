#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group lifecycle policies

.DESCRIPTION
    Retrieves the properties and relationships of group lifecycle (expiration) policies defined under Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group to get associated policies for.

.PARAMETER GroupLifecyclePolicyId
    The unique identifier of the group lifecycle policy to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupLifecyclePolicy.ps1

.EXAMPLE
    PS> ./Get-MgmtGraphGroupLifecyclePolicy.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupLifecyclePolicy.ps1 -GroupLifecyclePolicyId "policy-id-456"

.CATEGORY Microsoft Graph
#>

[CmdletBinding(DefaultParameterSetName = 'ListAll')]
Param (
    [Parameter(Mandatory = $true, ParameterSetName = 'ByGroup', Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByPolicyId', Position = 0)]
    [string]$GroupLifecyclePolicyId
)

Process {
    try {
        $policies = $null
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup') {
            $params.Add('GroupId', $GroupId)
            $policies = Get-MgGroupLifecyclePolicyByGroup @params
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByPolicyId') {
            $params.Add('GroupLifecyclePolicyId', $GroupLifecyclePolicyId)
            $policies = Get-MgGroupLifecyclePolicy @params
        }
        else {
            $params.Add('All', $true)
            $policies = Get-MgGroupLifecyclePolicy @params
        }

        $results = foreach ($p in $policies) {
            [PSCustomObject]@{
                PolicyId                     = $p.Id
                GroupLifetimeInDays          = $p.GroupLifetimeInDays
                ManagedGroupTypes            = $p.ManagedGroupTypes
                AlternateNotificationEmails = $p.AlternateNotificationEmails
                Timestamp                    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
