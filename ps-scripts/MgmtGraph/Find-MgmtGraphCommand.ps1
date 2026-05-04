#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Searches for Microsoft Graph SDK commands and associated API details

.DESCRIPTION
    Searches for PowerShell commands within the Microsoft Graph SDK based on a command name, an API URI, or a specific HTTP method. Helps identify the correct cmdlet for a given Graph API endpoint.

.PARAMETER Command
    Specifies the name of the cmdlet to search for (wildcards supported).

.PARAMETER Uri
    Specifies the Microsoft Graph API URI to search for (e.g., "/users").

.PARAMETER Method
    Optional. Specifies the HTTP method to filter by (Get, Post, Put, Patch, Delete).

.PARAMETER ApiVersion
    Optional. Specifies the API version (v1.0, beta).

.EXAMPLE
    PS> ./Find-MgmtGraphCommand.ps1 -Uri "/users" -Method Get

.CATEGORY Microsoft Graph
#>

[CmdletBinding(DefaultParameterSetName = 'Command')]
Param (
    [Parameter(Mandatory = $true, ParameterSetName = 'Command')]
    [string]$Command,

    [Parameter(Mandatory = $true, ParameterSetName = 'Uri')]
    [string]$Uri,

    [Parameter(ParameterSetName = 'Uri')]
    [ValidateSet('Get', 'Post', 'Put', 'Patch', 'Delete')]
    [string]$Method,

    [ValidateSet('v1.0', 'beta')]
    [string]$ApiVersion = "v1.0"
)

Process {
    try {
        $params = @{
            'ApiVersion'  = $ApiVersion
            'ErrorAction' = 'Stop'
        }

        if ($PSCmdlet.ParameterSetName -eq 'Uri') {
            $params.Add('Uri', $Uri)
            if ($Method) { $params.Add('Method', $Method) }
        }
        else {
            $params.Add('Command', $Command)
        }

        $commands = Find-MgGraphCommand @params
        
        $results = foreach ($cmd in $commands) {
            [PSCustomObject]@{
                Command     = $cmd.Command
                Module      = $cmd.Module
                Method      = $cmd.Method
                Uri         = $cmd.Uri
                ApiVersion  = $cmd.ApiVersion
                Permissions = $cmd.Permissions | ForEach-Object { $_.Name }
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Command)
    }
    catch {
        throw
    }
}
