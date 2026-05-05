#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits sponsors for a Microsoft Graph guest user

.DESCRIPTION
    Retrieves the list of users and groups designated as sponsors for a guest account. Sponsors are responsible for managing the guest's access and profile details.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the guest user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserSponsor.ps1 -Identity "guest@external.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $sponsors = Get-MgUserSponsor -UserId $Identity -All -ErrorAction Stop
        
        $results = foreach ($s in $sponsors) {
            [PSCustomObject]@{
                DisplayName = $s.AdditionalProperties.displayName
                Type        = $s.AdditionalProperties.'@odata.type'.Replace('#microsoft.graph.', '')
                Mail        = $s.AdditionalProperties.mail
                Id          = $s.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
