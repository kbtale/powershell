#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Invokes a custom REST API request against Microsoft Graph

.DESCRIPTION
    Executes a direct REST API call to the Microsoft Graph endpoint using the specifies URI, HTTP method, and optional request body. Useful for calling APIs not yet covered by specific SDK cmdlets.

.PARAMETER Uri
    Specifies the relative Microsoft Graph API URI (e.g., "/me", "/users").

.PARAMETER Method
    Specifies the HTTP method for the request (GET, POST, PUT, PATCH, DELETE).

.PARAMETER Body
    Optional. Specifies the JSON request body for POST, PUT, or PATCH operations.

.EXAMPLE
    PS> ./Invoke-MgmtGraphRequest.ps1 -Uri "/me" -Method GET

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Uri,

    [Parameter(Mandatory = $true)]
    [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
    [string]$Method,

    [string]$Body
)

Process {
    try {
        $params = @{
            'Uri'         = $Uri
            'Method'      = $Method
            'ErrorAction' = 'Stop'
        }
        if ($Body) { $params.Add('Body', $Body) }

        $result = Invoke-MgGraphRequest @params
        
        Write-Output $result
    }
    catch {
        throw
    }
}
