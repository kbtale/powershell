#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Updates Microsoft Graph API request configuration

.DESCRIPTION
    Configures retry policies and timeouts for Microsoft Graph API requests, including client timeout, maximum retries, and retry delays.

.PARAMETER ClientTimeout
    Optional. Specifies the client timeout for requests (in seconds).

.PARAMETER MaxRetry
    Optional. Specifies the maximum number of retries for failed requests.

.PARAMETER RetryDelay
    Optional. Specifies the delay between retries (in seconds).

.PARAMETER RetriesTimeLimit
    Optional. Specifies the maximum time limit for retries (in seconds).

.EXAMPLE
    PS> ./Set-MgmtGraphRequestContext.ps1 -ClientTimeout 60 -MaxRetry 5

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [int]$ClientTimeout,
    [int]$MaxRetry,
    [int]$RetryDelay,
    [int]$RetriesTimeLimit
)

Process {
    try {
        $params = @{
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('ClientTimeout')) { $params.Add('ClientTimeout', $ClientTimeout) }
        if ($PSBoundParameters.ContainsKey('MaxRetry')) { $params.Add('MaxRetry', $MaxRetry) }
        if ($PSBoundParameters.ContainsKey('RetryDelay')) { $params.Add('RetryDelay', $RetryDelay) }
        if ($PSBoundParameters.ContainsKey('RetriesTimeLimit')) { $params.Add('RetriesTimeLimit', $RetriesTimeLimit) }

        if ($params.Count -gt 2) {
            Set-MgRequestContext @params
            
            $result = [PSCustomObject]@{
                ClientTimeout    = $ClientTimeout
                MaxRetry         = $MaxRetry
                RetryDelay       = $RetryDelay
                RetriesTimeLimit = $RetriesTimeLimit
                Action           = "RequestContextUpdated"
                Status           = "Success"
                Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for request context."
        }
    }
    catch {
        throw
    }
}
