#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets app as featured
.DESCRIPTION
    Marks a PowerApp as featured.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-PowerAppAsFeatured.ps1 -PACredential $cred -AppName "my-app"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; AppName = $AppName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $null = Set-AdminPowerAppAsFeatured @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "App '$AppName' set as featured" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
