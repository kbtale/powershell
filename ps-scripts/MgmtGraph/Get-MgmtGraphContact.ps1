#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits organizational contacts in Microsoft Graph

.DESCRIPTION
    Retrieves properties for a specifies organizational contact or lists all contacts in the tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the organizational contact to retrieve. If omitted, all contacts are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphContact.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Identity) {
            $params.Add('OrgContactId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $contacts = Get-MgContact @params
        
        $results = foreach ($c in $contacts) {
            [PSCustomObject]@{
                DisplayName = $c.DisplayName
                Id          = $c.Id
                Mail        = $c.Mail
                JobTitle    = $c.JobTitle
                Department  = $c.Department
                CompanyName = $c.CompanyName
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
