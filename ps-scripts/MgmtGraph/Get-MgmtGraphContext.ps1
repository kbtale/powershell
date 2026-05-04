#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Audits the current Microsoft Graph connection context

.DESCRIPTION
    Retrieves the current authentication context for the Microsoft Graph SDK, including the account name, tenant ID, environment, and active scopes.

.EXAMPLE
    PS> ./Get-MgmtGraphContext.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $context = Get-MgContext -ErrorAction Stop
        
        if (-not $context) {
            Write-Warning "No active Microsoft Graph context found. Please connect first."
            return
        }

        $result = [PSCustomObject]@{
            Account       = $context.Account
            TenantId      = $context.TenantId
            Environment   = $context.Environment
            Scopes        = $context.Scopes
            AuthType      = $context.AuthType
            CertificateThumbprint = $context.CertificateThumbprint
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
