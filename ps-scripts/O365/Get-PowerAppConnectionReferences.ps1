#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves app connection references
.DESCRIPTION
    Returns connection references for a specified PowerApp.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER EnvironmentName
    Environment where the PowerApp is located
.PARAMETER AppName
    PowerApp to list connection references for
.EXAMPLE
    PS> ./Get-PowerAppConnectionReferences.ps1 -PACredential $cred -EnvironmentName "default" -AppName "my-app"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true)]
    [string]$AppName
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop'; AppName = $AppName; EnvironmentName = $EnvironmentName }
        $result = Get-AdminPowerAppConnectionReferences @getArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
