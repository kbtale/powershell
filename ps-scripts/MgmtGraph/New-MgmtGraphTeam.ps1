#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Provisions a new Microsoft Team

.DESCRIPTION
    Creates a new Microsoft Team based on the standard template. Requires a specifies owner (UPN or ID).

.PARAMETER DisplayName
    Specifies the display name for the new Team.

.PARAMETER TeamOwner
    Specifies the UserPrincipalName or ID of the user who will be the initial owner of the Team.

.PARAMETER Description
    Optional. Specifies a description for the Team.

.PARAMETER Visibility
    Specifies the visibility level of the Team. Valid values: Public, Private.

.EXAMPLE
    PS> ./New-MgmtGraphTeam.ps1 -DisplayName "Sales Dept" -TeamOwner "admin@example.com" -Visibility "Private"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [string]$TeamOwner,

    [string]$Description,

    [ValidateSet('Public', 'Private')]
    [string]$Visibility = 'Public'
)

Process {
    try {
        $params = @{
            'DisplayName' = $DisplayName
            'Visibility'  = $Visibility
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
            'AdditionalProperties' = @{
                "template@odata.bind" = "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
            }
            'Members' = @(
                @{
                    "@odata.type" = "#microsoft.graph.aadUserConversationMember"
                    Roles         = @("owner")
                    "User@odata.bind" = "https://graph.microsoft.com/v1.0/users('$($TeamOwner)')"
                }
            )
        }

        if ($Description) { $params.Add('Description', $Description) }

        $team = New-MgTeam @params
        
        $result = [PSCustomObject]@{
            DisplayName = $DisplayName
            Id          = $team.Id
            Visibility  = $Visibility
            Status      = "TeamCreated"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
