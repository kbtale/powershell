#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Audits current Microsoft Graph SDK operational options

.DESCRIPTION
    Retrieves the current operational options for the Microsoft Graph SDK, such as the active profile (v1.0 or beta) and other SDK-level configurations.

.EXAMPLE
    PS> ./Get-MgmtGraphOption.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $options = Get-MgGraphOption -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            Profile       = $options.Profile
            ApiVersion    = $options.ApiVersion
            ContextScope  = $options.ContextScope
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
