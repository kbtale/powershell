#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Lists registered Microsoft Graph cloud environments

.DESCRIPTION
    Retrieves a list of all registered Microsoft Graph environments (e.g., Global, USGov, China) and their associated endpoints.

.PARAMETER Name
    Optional. Filters the list by a specific environment name (wildcards supported).

.EXAMPLE
    PS> ./Get-MgmtGraphEnvironment.ps1 -Name "Global"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [string]$Name
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }
        if ($Name) { $params.Add('Name', $Name) }

        $environments = Get-MgEnvironment @params
        
        $results = foreach ($env in $environments) {
            [PSCustomObject]@{
                Name            = $env.Name
                AzureADEndpoint = $env.AzureADEndpoint
                GraphEndpoint   = $env.GraphEndpoint
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
