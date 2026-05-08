#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Return the policy assignments for a user
.DESCRIPTION
    Retrieves the policy assignments for a specified user. Supports optional filtering by PolicyType.
.PARAMETER Identity
    The user that will get their assigned policies
.PARAMETER PolicyType
    The type of the policy to filter
.EXAMPLE
    PS> ./Get-MSTUserPolicyAssignment.ps1 -Identity "user@domain.com"
.EXAMPLE
    PS> ./Get-MSTUserPolicyAssignment.ps1 -Identity "user@domain.com" -PolicyType "TeamsMeetingPolicy"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [ValidateSet('CallingLineIdentity','OnlineVoiceRoutingPolicy','TeamsAppSetupPolicy','TeamsAppPermissionPolicy','TeamsCallingPolicy','TeamsCallParkPolicy','TeamsChannelsPolicy','TeamsEducationAssignmentsAppPolicy','TeamsEmergencyCallingPolicy','TeamsMeetingBroadcastPolicy','TeamsEmergencyCallRoutingPolicy','TeamsMeetingPolicy','TeamsMessagingPolicy','TeamsUpdateManagementPolicy','TeamsUpgradePolicy','TeamsVerticalPackagePolicy','TeamsVideoInteropServicePolicy','TenantDialPlan')]
    [string]$PolicyType
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        if (-not [System.String]::IsNullOrWhiteSpace($PolicyType)) {
            $getArgs.Add('PolicyType', $PolicyType)
        }

        $result = Get-CsUserPolicyAssignment @getArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "No user policy assignments found"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
