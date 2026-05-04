#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Unregisters a custom Microsoft Graph cloud environment

.DESCRIPTION
    Removes a specifies custom Microsoft Graph environment from the local registration. Standard environments (Global, USGov, etc.) cannot be removed.

.PARAMETER Name
    Specifies the name of the environment to unregister.

.EXAMPLE
    PS> ./Remove-MgmtGraphEnvironment.ps1 -Name "CustomCloud"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name
)

Process {
    try {
        $params = @{
            'Name'        = $Name
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgEnvironment @params
        
        $result = [PSCustomObject]@{
            Name      = $Name
            Action    = "EnvironmentUnregistered"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
