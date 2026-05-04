#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Updates endpoints for a registered Microsoft Graph cloud environment

.DESCRIPTION
    Updates the Azure AD and Graph endpoints for a previously registered Microsoft Graph environment. This is typically used for custom or private cloud configurations.

.PARAMETER Name
    Specifies the name of the environment to update.

.PARAMETER AzureADEndpoint
    Optional. Specifies the new Azure AD endpoint URL.

.PARAMETER GraphEndpoint
    Optional. Specifies the new Microsoft Graph endpoint URL.

.EXAMPLE
    PS> ./Set-MgmtGraphEnvironment.ps1 -Name "CustomCloud" -GraphEndpoint "https://new-graph.example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$AzureADEndpoint,

    [string]$GraphEndpoint
)

Process {
    try {
        $params = @{
            'Name'        = $Name
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($AzureADEndpoint) { $params.Add('AzureADEndpoint', $AzureADEndpoint) }
        if ($GraphEndpoint) { $params.Add('GraphEndpoint', $GraphEndpoint) }

        if ($params.Count -gt 3) {
            $env = Set-MgEnvironment @params
            
            $result = [PSCustomObject]@{
                Name            = $env.Name
                AzureADEndpoint = $env.AzureADEndpoint
                GraphEndpoint   = $env.GraphEndpoint
                Action          = "EnvironmentUpdated"
                Status          = "Success"
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for environment '$Name'."
        }
    }
    catch {
        throw
    }
}
