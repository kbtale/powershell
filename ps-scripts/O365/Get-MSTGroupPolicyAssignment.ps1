#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Returns group policy assignments
.DESCRIPTION
    Retrieves group policy assignments from the tenant. Supports optional filtering by GroupId and PolicyType.
.PARAMETER GroupId
    Object ID of the group
.PARAMETER PolicyType
    The type of the policy to filter
.EXAMPLE
    PS> ./Get-MSTGroupPolicyAssignment.ps1
.EXAMPLE
    PS> ./Get-MSTGroupPolicyAssignment.ps1 -GroupId "group-id" -PolicyType "TeamsMeetingPolicy"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$GroupId,
    [ValidateSet('TeamsAppSetupPolicy','TeamsCallingPolicy','TeamsCallParkPolicy','TeamsChannelsPolicy','TeamsComplianceRecordingPolicy','TeamsEducationAssignmentsAppPolicy','TeamsMeetingBroadcastPolicy','TeamsMeetingPolicy','TeamsMessagingPolicy')]
    [string]$PolicyType
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}

        if (-not [System.String]::IsNullOrWhiteSpace($PolicyType)) {
            $getArgs.Add('PolicyType', $PolicyType)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($GroupId)) {
            $getArgs.Add('GroupId', $GroupId)
        }

        $result = Get-CsGroupPolicyAssignment @getArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No group policy assignments found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
