#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves tenant graph details
.DESCRIPTION
    Returns tenant details from Microsoft Graph using the admin connection.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER GraphApiVersion
    The Graph API version to call
.EXAMPLE
    PS> ./Get-TenantGraphDetails-Admin.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$GraphApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('GraphApiVersion')) { $args.Add('GraphApiVersion', $GraphApiVersion) }
        $result = Get-TenantDetailsFromGraph @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
