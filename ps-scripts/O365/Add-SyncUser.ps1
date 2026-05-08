#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Adds a sync user
.DESCRIPTION
    Adds a user to the PowerApps sync list.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER UserName
    The user to add for sync
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Add-SyncUser.ps1 -PACredential $cred -UserName "user@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; UserPrincipalName = $UserName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $null = Add-AdminPowerAppSyncUser @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Sync user '$UserName' added" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
