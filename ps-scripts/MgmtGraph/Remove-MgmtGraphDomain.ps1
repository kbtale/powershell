#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Deletes a Microsoft Graph domain

.DESCRIPTION
    Removes a specifies domain from the Microsoft Graph tenant. This action is only possible for non-initial, non-verified, or verified domains that are not currently in use.

.PARAMETER Identity
    Specifies the name of the domain to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphDomain.ps1 -Identity "olddomain.com"

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

        Remove-MgDomain @params
        
        $result = [PSCustomObject]@{
            DomainName = $Identity
            Action     = "DomainRemoved"
            Status     = "Success"
            Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
