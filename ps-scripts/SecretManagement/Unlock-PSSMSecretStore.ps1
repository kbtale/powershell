#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Unlocks the SecretStore
.DESCRIPTION
    Unlocks the SecretStore extension vault using the provided password.
.PARAMETER StorePassword
    Password to unlock the SecretStore
.EXAMPLE
    PS> ./Unlock-PSSMSecretStore.ps1 -StorePassword (Read-Host -AsSecureString)
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [securestring]$StorePassword
)

Process {
    try {
        Unlock-SecretStore -Password $StorePassword -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "SecretStore unlocked" }
    }
    catch { throw }
}
