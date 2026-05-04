#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits the manager of an organizational contact

.DESCRIPTION
    Retrieves the manager details (User or Contact) for a specifies organizational contact in Microsoft Graph.

.PARAMETER Identity
    Specifies the ID of the organizational contact to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphContactManager.ps1 -Identity "contact-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $manager = Get-MgContactManager -OrgContactId $Identity -ErrorAction Stop
        
        if ($manager) {
            $result = [PSCustomObject]@{
                ContactId   = $Identity
                DisplayName = $manager.AdditionalProperties.displayName
                Type        = $manager.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Id          = $manager.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
    }
    catch {
        throw
    }
}
