#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Graph domains

.DESCRIPTION
    Retrieves properties for a specifies domain or lists all domains registered in the Microsoft Graph tenant, including verification status and authentication type.

.PARAMETER Identity
    Optional. Specifies the name of the domain to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphDomain.ps1

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
            $params.Add('DomainId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $domains = Get-MgDomain @params
        
        $results = foreach ($d in $domains) {
            [PSCustomObject]@{
                DomainName         = $d.Id
                IsDefault          = $d.IsDefault
                IsVerified         = $d.IsVerified
                AuthenticationType = $d.AuthenticationType
                IsRoot             = $d.IsRoot
                IsInitial          = $d.IsInitial
                Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DomainName)
    }
    catch {
        throw
    }
}
