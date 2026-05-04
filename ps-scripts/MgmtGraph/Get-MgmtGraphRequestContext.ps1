#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Audits current Microsoft Graph API request metadata

.DESCRIPTION
    Retrieves the current request context for Microsoft Graph API calls, including client request IDs and other metadata used for tracking and troubleshooting.

.EXAMPLE
    PS> ./Get-MgmtGraphRequestContext.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $context = Get-MgRequestContext -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            ClientRequestId = $context.ClientRequestId
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
