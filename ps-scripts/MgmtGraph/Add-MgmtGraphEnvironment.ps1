#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Registers a custom Microsoft Graph cloud environment

.DESCRIPTION
    Registers a new Microsoft Graph environment with specifies Azure AD and Graph endpoints. This is useful for national clouds (e.g., Azure Germany, Azure China) or custom on-premises gateways.

.PARAMETER Name
    Specifies the name of the environment to register.

.PARAMETER AzureADEndpoint
    Specifies the Azure AD endpoint URL for the environment.

.PARAMETER GraphEndpoint
    Specifies the Microsoft Graph endpoint URL for the environment.

.EXAMPLE
    PS> ./Add-MgmtGraphEnvironment.ps1 -Name "CustomCloud" -AzureADEndpoint "https://login.microsoftonline.de" -GraphEndpoint "https://graph.microsoft.de"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$AzureADEndpoint,

    [Parameter(Mandatory = $true)]
    [string]$GraphEndpoint
)

Process {
    try {
        $params = @{
            'Name'            = $Name
            'AzureADEndpoint' = $AzureADEndpoint
            'GraphEndpoint'   = $GraphEndpoint
            'ErrorAction'     = 'Stop'
        }

        $env = Add-MgEnvironment @params
        
        $result = [PSCustomObject]@{
            Name            = $env.Name
            AzureADEndpoint = $env.AzureADEndpoint
            GraphEndpoint   = $env.GraphEndpoint
            Status          = "EnvironmentRegistered"
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
