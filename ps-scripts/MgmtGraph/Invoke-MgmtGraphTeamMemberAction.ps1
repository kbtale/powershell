#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Manages membership actions for a Microsoft Team

.DESCRIPTION
    Adds or removes members from a specifies Microsoft Team. Supports role assignment (owner/member).

.PARAMETER Identity
    Specifies the ID of the Team.

.PARAMETER AddMember
    Optional. Specifies an array of User IDs to add to the Team.

.PARAMETER RemoveMember
    Optional. Specifies an array of Membership IDs (not User IDs) to remove from the Team.

.PARAMETER Role
    Optional. Specifies the role for added members. Valid values: owner, member. Default is member.

.EXAMPLE
    PS> ./Invoke-MgmtGraphTeamMemberAction.ps1 -Identity "team-id" -AddMember "user-id" -Role "owner"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string[]]$AddMember,

    [string[]]$RemoveMember,

    [ValidateSet('owner', 'member')]
    [string]$Role = 'member'
)

Process {
    try {
        # Handle Additions
        foreach ($id in $AddMember) {
            $roles = if ($Role -eq 'owner') { @("owner") } else { @() }
            $params = @{
                'TeamId'           = $Identity
                'Roles'            = $roles
                'AdditionalProperties' = @{
                    "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('$id')"
                }
                'ErrorAction'      = 'Stop'
            }
            New-MgTeamMember @params
        }

        # Handle Removals
        foreach ($mid in $RemoveMember) {
            $params = @{
                'TeamId'             = $Identity
                'ConversationMemberId' = $mid
                'ErrorAction'        = 'Stop'
            }
            Remove-MgTeamMember @params
        }

        $result = [PSCustomObject]@{
            TeamId       = $Identity
            AddedCount   = ($AddMember | Measure-Object).Count
            RemovedCount = ($RemoveMember | Measure-Object).Count
            Action       = "TeamMemberActionExecuted"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
