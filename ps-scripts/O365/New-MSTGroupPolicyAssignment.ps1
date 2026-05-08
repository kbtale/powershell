#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Assign a policy to a security group or distribution list
.DESCRIPTION
    Assigns a policy to a security group or distribution list in the tenant.
.PARAMETER GroupId
    Object ID of the group
.PARAMETER PolicyType
    The type of the policy
.PARAMETER PolicyName
    The name of the policy to assign
.PARAMETER Rank
    The rank of the policy assignment
.EXAMPLE
    PS> ./New-MSTGroupPolicyAssignment.ps1 -GroupId "group-id" -PolicyType "TeamsMeetingPolicy" -PolicyName "MyPolicy"
.EXAMPLE
    PS> ./New-MSTGroupPolicyAssignment.ps1 -GroupId "group-id" -PolicyType "TeamsMessagingPolicy" -PolicyName "MyPolicy" -Rank 1
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('TeamsAppSetupPolicy','TeamsCallingPolicy','TeamsCallParkPolicy','TeamsChannelsPolicy','TeamsComplianceRecordingPolicy','TeamsEducationAssignmentsAppPolicy','TeamsMeetingBroadcastPolicy','TeamsMeetingPolicy','TeamsMessagingPolicy')]
    [string]$PolicyType,
    [Parameter(Mandatory = $true)]
    [string]$PolicyName,
    [int]$Rank
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'PolicyType' = $PolicyType; 'PolicyName' = $PolicyName}

        if ($PSBoundParameters.ContainsKey('Rank')) {
            $cmdArgs.Add('Rank', $Rank)
        }

        $result = New-CsGroupPolicyAssignment @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Group policy assigned"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
