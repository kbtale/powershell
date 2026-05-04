#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Audits members of a Microsoft Graph group

.DESCRIPTION
    Retrieves the list of members for a specifies Microsoft Graph group, including users, groups, and service principals.

.PARAMETER Identity
    Specifies the ID of the group to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMember.ps1 -Identity "86c75b0a-..."

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $members = Get-MgGroupMember -GroupId $Identity -All -ErrorAction Stop
        
        $results = foreach ($m in $members) {
            [PSCustomObject]@{
                DisplayName = $m.AdditionalProperties.displayName
                Type        = $m.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Mail        = $m.AdditionalProperties.mail
                Id          = $m.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
