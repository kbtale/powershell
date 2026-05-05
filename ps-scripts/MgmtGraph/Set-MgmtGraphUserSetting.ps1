#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Updates settings for a Microsoft Graph user

.DESCRIPTION
    Updates personal settings for a specifies Microsoft Graph user, such as document discovery preferences in Office Delve.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to update.

.PARAMETER DiscoveryDisabled
    Optional. If set to $true, disables document discovery in Office Delve for the user.

.PARAMETER OrgDiscoveryDisabled
    Optional. If set to $true, reflects the organization-level setting for discovery.

.EXAMPLE
    PS> ./Set-MgmtGraphUserSetting.ps1 -Identity "user@example.com" -DiscoveryDisabled $true

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [bool]$DiscoveryDisabled,

    [bool]$OrgDiscoveryDisabled
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DiscoveryDisabled')) { $params.Add('ContributionToContentDiscoveryDisabled', $DiscoveryDisabled) }
        if ($PSBoundParameters.ContainsKey('OrgDiscoveryDisabled')) { $params.Add('ContributionToContentDiscoveryAsOrganizationDisabled', $OrgDiscoveryDisabled) }

        if ($params.Count -gt 3) {
            Update-MgUserSetting @params
            
            $result = [PSCustomObject]@{
                UserIdentity = $Identity
                Action       = "UserSettingUpdated"
                Status       = "Success"
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for user settings."
        }
    }
    catch {
        throw
    }
}
