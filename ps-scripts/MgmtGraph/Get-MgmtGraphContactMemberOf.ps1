#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits group membership for an organizational contact

.DESCRIPTION
    Retrieves the list of groups (Security or M365) that a specifies organizational contact is a member of.

.PARAMETER Identity
    Specifies the ID of the organizational contact to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphContactMemberOf.ps1 -Identity "contact-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $groups = Get-MgContactMemberOf -OrgContactId $Identity -All -ErrorAction Stop
        
        $results = foreach ($g in $groups) {
            [PSCustomObject]@{
                DisplayName = $g.AdditionalProperties.displayName
                Type        = $g.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Id          = $g.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
