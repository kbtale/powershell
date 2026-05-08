#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of user policy assignments
.DESCRIPTION
    Generates an HTML report with the policy assignments for a specific user.
.PARAMETER Identity
    The user that will get their assigned policies
.PARAMETER PolicyType
    The type of the policy to filter
.EXAMPLE
    PS> ./Get-MSTUserPolicyAssignment-Html.ps1 -Identity "user@domain.com" | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTUserPolicyAssignment-Html.ps1 -Identity "user@domain.com" -PolicyType "TeamsMeetingPolicy" | Out-File report.html
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

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
