#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Remove a group policy assignment
.DESCRIPTION
    Removes a policy assignment from a security group or distribution list.
.PARAMETER GroupId
    Object ID of the group
.PARAMETER PolicyType
    The type of the policy to remove
.EXAMPLE
    PS> ./Remove-MSTGroupPolicyAssignment.ps1 -GroupId "group-id" -PolicyType "TeamsMeetingPolicy"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('TeamsAppSetupPolicy','TeamsCallingPolicy','TeamsCallParkPolicy','TeamsChannelsPolicy','TeamsComplianceRecordingPolicy','TeamsEducationAssignmentsAppPolicy','TeamsMeetingBroadcastPolicy','TeamsMeetingPolicy','TeamsMessagingPolicy')]
    [string]$PolicyType
)

Process {
    try {
        [hashtable]$remArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'PolicyType' = $PolicyType}

        $null = Remove-CsGroupPolicyAssignment @remArgs

        [PSCustomObject]@{
            Timestamp  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            GroupId    = $GroupId
            PolicyType = $PolicyType
            Status     = 'Group policy assignment successfully removed'
        }
    }
    catch { throw }
}
