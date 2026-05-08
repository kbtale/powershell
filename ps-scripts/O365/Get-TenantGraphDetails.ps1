#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves tenant graph details
.DESCRIPTION
    Returns tenant details from Microsoft Graph.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER GraphApiVersion
    The Graph API version to call
.EXAMPLE
    PS> ./Get-TenantGraphDetails.ps1 -PACredential $cred
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
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('GraphApiVersion')) { $getArgs.Add('GraphApiVersion', $GraphApiVersion) }
        $result = Get-TenantDetailsFromGraph @getArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
