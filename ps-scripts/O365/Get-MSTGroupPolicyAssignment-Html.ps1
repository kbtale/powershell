#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of group policy assignments
.DESCRIPTION
    Generates an HTML report with group policy assignments in the tenant.
.PARAMETER GroupId
    Specify the GroupId to filter
.PARAMETER PolicyType
    The type of the policy to filter
.EXAMPLE
    PS> ./Get-MSTGroupPolicyAssignment-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTGroupPolicyAssignment-Html.ps1 -PolicyType "TeamsMeetingPolicy" | Out-File report.html
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

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
