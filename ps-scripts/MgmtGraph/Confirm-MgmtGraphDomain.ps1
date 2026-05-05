#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Confirms Microsoft Graph domain ownership

.DESCRIPTION
    Triggers the verification process for a specifies domain. This should be run after the required DNS verification records have been published.

.PARAMETER Identity
    Specifies the name of the domain to confirm.

.EXAMPLE
    PS> ./Confirm-MgmtGraphDomain.ps1 -Identity "contoso.com"

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
            'DomainId'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        $domain = Confirm-MgDomain @params
        
        $result = [PSCustomObject]@{
            DomainName = $domain.Id
            IsVerified = $domain.IsVerified
            Action     = "DomainVerificationTriggered"
            Status     = "Success"
            Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
