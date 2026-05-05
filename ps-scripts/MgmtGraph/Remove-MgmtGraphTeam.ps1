#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams, Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Deletes a Microsoft Team

.DESCRIPTION
    Deletes a specifies Microsoft Team by removing its underlying Microsoft 365 Group. This action is permanent.

.PARAMETER Identity
    Specifies the ID of the Team to delete.

.EXAMPLE
    PS> ./Remove-MgmtGraphTeam.ps1 -Identity "team-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'GroupId'     = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgGroup @params
        
        $result = [PSCustomObject]@{
            TeamId    = $Identity
            Action    = "TeamRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
