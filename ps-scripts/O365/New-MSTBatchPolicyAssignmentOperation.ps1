#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Create a batch policy assignment operation
.DESCRIPTION
    Submits an operation that applies a policy to a batch of users in the tenant.
.PARAMETER Identities
    A list of one or more users in the tenant
.PARAMETER PolicyName
    The name of the policy to apply
.PARAMETER PolicyType
    The type of the policy
.PARAMETER OperationName
    Custom name for the operation
.EXAMPLE
    PS> ./New-MSTBatchPolicyAssignmentOperation.ps1 -Identities @("user1@domain.com") -PolicyName "MyPolicy" -PolicyType "TeamsMeetingPolicy"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string[]]$Identities,
    [Parameter(Mandatory = $true)]
    [string]$PolicyName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('CallingLineIdentity','OnlineVoiceRoutingPolicy','TeamsAppSetupPolicy','TeamsAppPermissionPolicy','TeamsCallingPolicy','TeamsCallParkPolicy','TeamsChannelsPolicy','TeamsEducationAssignmentsAppPolicy','TeamsEmergencyCallingPolicy','TeamsMeetingBroadcastPolicy','TeamsEmergencyCallRoutingPolicy','TeamsMeetingPolicy','TeamsMessagingPolicy','TeamsUpdateManagementPolicy','TeamsUpgradePolicy','TeamsVerticalPackagePolicy','TeamsVideoInteropServicePolicy','TenantDialPlan')]
    [string]$PolicyType,
    [string]$OperationName
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identities; 'PolicyName' = $PolicyName; 'PolicyType' = $PolicyType}
        if (-not [System.String]::IsNullOrWhiteSpace($OperationName)) {
            $cmdArgs.Add('OperationName', $OperationName)
        }

        $opid = New-CsBatchPolicyAssignmentOperation @cmdArgs
        $result = Get-CsBatchPolicyAssignmentOperation -OperationID $opid -ErrorAction Stop | Select-Object *

        if ($null -eq $result) {
            Write-Output "Batch operation submitted"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
