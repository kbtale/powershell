#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Updates Microsoft Graph SDK operational options

.DESCRIPTION
    Configures operational options for the Microsoft Graph SDK, such as enabling Windows Account Manager (WAM) for login.

.PARAMETER EnableLoginByWAM
    Specifies whether to enable login using Windows Account Manager (WAM).

.EXAMPLE
    PS> ./Set-MgmtGraphOption.ps1 -EnableLoginByWAM $true

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [bool]$EnableLoginByWAM
)

Process {
    try {
        $options = Set-MgGraphOption -EnableLoginByWAM $EnableLoginByWAM -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            EnableLoginByWAM = $EnableLoginByWAM
            Action           = "GraphOptionsUpdated"
            Status           = "Success"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
