#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits direct reports for an organizational contact

.DESCRIPTION
    Retrieves the list of directory objects (Users or Contacts) that report directly to a specifies organizational contact.

.PARAMETER Identity
    Specifies the ID of the organizational contact to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphContactDirectReport.ps1 -Identity "contact-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $reports = Get-MgContactDirectReport -OrgContactId $Identity -All -ErrorAction Stop
        
        $results = foreach ($r in $reports) {
            [PSCustomObject]@{
                DisplayName = $r.AdditionalProperties.displayName
                Type        = $r.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Mail        = $r.AdditionalProperties.mail
                Id          = $r.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
