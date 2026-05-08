#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Update a group policy assignment
.DESCRIPTION
    Updates a group policy assignment. Supports changing the policy name and rank.
.PARAMETER GroupId
    Object ID of the group
.PARAMETER PolicyType
    The type of the policy
.PARAMETER PolicyName
    The new policy name to assign
.PARAMETER Rank
    The new rank of the policy assignment
.EXAMPLE
    PS> ./Set-MSTGroupPolicyAssignment.ps1 -GroupId "group-id" -PolicyType "TeamsMeetingPolicy" -PolicyName "NewPolicy"
.EXAMPLE
    PS> ./Set-MSTGroupPolicyAssignment.ps1 -GroupId "group-id" -PolicyType "TeamsMessagingPolicy" -PolicyName "MyPolicy" -Rank 2
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('TeamsAppSetupPolicy','TeamsCallingPolicy','TeamsCallParkPolicy','TeamsChannelsPolicy','TeamsComplianceRecordingPolicy','TeamsEducationAssignmentsAppPolicy','TeamsMeetingBroadcastPolicy','TeamsMeetingPolicy','TeamsMessagingPolicy')]
    [string]$PolicyType,
    [string]$PolicyName,
    [int]$Rank
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'PolicyType' = $PolicyType}

        if (-not [System.String]::IsNullOrWhiteSpace($PolicyName)) {
            $cmdArgs.Add('PolicyName', $PolicyName)
        }
        if ($PSBoundParameters.ContainsKey('Rank')) {
            $cmdArgs.Add('Rank', $Rank)
        }

        $result = Set-CsGroupPolicyAssignment @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Group policy assignment updated"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
