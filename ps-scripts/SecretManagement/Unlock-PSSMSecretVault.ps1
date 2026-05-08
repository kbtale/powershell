#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
.SYNOPSIS
    SecretManagement: Unlocks a secret vault
.DESCRIPTION
    Unlocks a registered secret vault using the specified password.
.PARAMETER VaultName
    Name of the vault to unlock
.PARAMETER StorePassword
    Password to unlock the vault
.EXAMPLE
    PS> ./Unlock-PSSMSecretVault.ps1 -VaultName "MyVault" -StorePassword (Read-Host -AsSecureString)
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName,

    [Parameter(Mandatory = $true)]
    [securestring]$StorePassword
)

Process {
    try {
        Unlock-SecretVault -Name $VaultName -Password $StorePassword -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; VaultName = $VaultName; Message = "Vault '$VaultName' unlocked" }
    }
    catch { throw }
}
