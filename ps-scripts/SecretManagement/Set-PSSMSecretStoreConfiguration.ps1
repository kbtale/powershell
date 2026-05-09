#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Configures the SecretStore
.DESCRIPTION
    Configures the SecretStore authentication method, password, and timeout.
.PARAMETER Authentication
    Authentication method: None or Password
.PARAMETER StorePassword
    Password for SecretStore access
.PARAMETER PasswordTimeout
    Seconds the store remains unlocked after authentication
.PARAMETER Default
    Reset to default configuration
.EXAMPLE
    PS> ./Set-PSSMSecretStoreConfiguration.ps1 -Authentication "Password" -StorePassword (Read-Host -AsSecureString)
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [ValidateSet('None', 'Password')]
    [string]$Authentication,

    [securestring]$StorePassword,
    [int]$PasswordTimeout = 900,
    [switch]$Default
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; PassThru = $null; Confirm = $false }
        if ($Default) { $cmdArgs.Add('Default', $true) }
        else {
            if ($PSBoundParameters.ContainsKey('Authentication')) { $cmdArgs.Add('Authentication', $Authentication) }
            if ($PSBoundParameters.ContainsKey('StorePassword')) { $cmdArgs.Add('Password', $StorePassword) }
            if ($PSBoundParameters.ContainsKey('PasswordTimeout')) { $cmdArgs.Add('PasswordTimeout', $PasswordTimeout) }
        }
        $result = Set-SecretStoreConfiguration @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
