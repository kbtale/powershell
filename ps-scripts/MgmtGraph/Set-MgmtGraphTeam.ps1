#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Updates Microsoft Team properties

.DESCRIPTION
    Modifies configuration details for a specifies Team, such as its display name, description, and visibility.

.PARAMETER Identity
    Specifies the ID of the Team to update.

.PARAMETER DisplayName
    Optional. Specifies the new display name for the Team.

.PARAMETER Description
    Optional. Specifies the new description for the Team.

.PARAMETER Visibility
    Optional. Specifies the new visibility level. Valid values: Public, Private.

.EXAMPLE
    PS> ./Set-MgmtGraphTeam.ps1 -Identity "team-id" -DisplayName "New Team Name"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$DisplayName,

    [string]$Description,

    [ValidateSet('Public', 'Private')]
    [string]$Visibility
)

Process {
    try {
        $params = @{
            'TeamId'      = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DisplayName')) { $params.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('Description')) { $params.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('Visibility')) { $params.Add('Visibility', $Visibility) }

        if ($params.Count -gt 3) {
            Update-MgTeam @params
            
            $result = [PSCustomObject]@{
                TeamId    = $Identity
                Action    = "TeamUpdated"
                Status    = "Success"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for Team."
        }
    }
    catch {
        throw
    }
}
