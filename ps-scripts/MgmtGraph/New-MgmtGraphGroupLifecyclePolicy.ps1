#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Creates a new group lifecycle policy

.DESCRIPTION
    Creates a new group lifecycle (expiration) policy for unified groups in Microsoft Graph, setting lifetime limits, target scopes, and alternative email alerts.

.PARAMETER AlternateNotificationEmails
    Semicolon-separated list of email addresses to send expiration notifications to for groups without active owners.

.PARAMETER GroupLifetimeInDays
    The number of days a group can exist before it must be renewed. Default is 180 days.

.PARAMETER ManagedGroupType
    The scope of groups to which this policy applies. Default is 'None'. Supported values: All, Selected, None.

.EXAMPLE
    PS> ./New-MgmtGraphGroupLifecyclePolicy.ps1 -AlternateNotificationEmails "admin@domain.com" -GroupLifetimeInDays 365

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$AlternateNotificationEmails,

    [int]$GroupLifetimeInDays = 180,

    [ValidateSet('All', 'Selected', 'None')]
    [string]$ManagedGroupType = 'None'
)

Process {
    try {
        $params = @{
            'AlternateNotificationEmails' = $AlternateNotificationEmails
            'GroupLifetimeInDays'         = $GroupLifetimeInDays
            'ManagedGroupTypes'           = $ManagedGroupType
            'Confirm'                     = $false
            'ErrorAction'                 = 'Stop'
        }

        $policy = New-MgGroupLifecyclePolicy @params

        $result = [PSCustomObject]@{
            PolicyId                     = $policy.Id
            GroupLifetimeInDays          = $policy.GroupLifetimeInDays
            ManagedGroupTypes            = $policy.ManagedGroupTypes
            AlternateNotificationEmails = $policy.AlternateNotificationEmails
            Timestamp                    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
