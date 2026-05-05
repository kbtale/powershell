#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Provisions a new Microsoft Graph domain

.DESCRIPTION
    Adds a new domain to the Microsoft Graph tenant. The domain will be in an unverified state until ownership is confirmed.

.PARAMETER Identity
    Specifies the name of the domain to add (e.g., "contoso.com").

.EXAMPLE
    PS> ./New-MgmtGraphDomain.ps1 -Identity "newdomain.com"

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
            'Id'          = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        $domain = New-MgDomain @params
        
        $result = [PSCustomObject]@{
            DomainName = $domain.Id
            IsVerified = $domain.IsVerified
            Status     = "DomainAdded"
            Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
