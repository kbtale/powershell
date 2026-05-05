#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Audits owners of a Microsoft Graph group

.DESCRIPTION
    Retrieves the list of owners for a specifies Microsoft Graph group, including users and service principals.

.PARAMETER Identity
    Specifies the ID of the group to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupOwner.ps1 -Identity "group-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $owners = Get-MgGroupOwner -GroupId $Identity -All -ErrorAction Stop
        
        $results = foreach ($o in $owners) {
            [PSCustomObject]@{
                DisplayName = $o.AdditionalProperties.displayName
                Type        = $o.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Mail        = $o.AdditionalProperties.mail
                Id          = $o.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
