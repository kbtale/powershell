#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
.SYNOPSIS
    SecretManagement: Unregisters a secret vault
.DESCRIPTION
    Unregisters a SecretManagement extension vault for the current user.
.PARAMETER VaultName
    Name of the vault to unregister
.EXAMPLE
    PS> ./Unregister-PSSMSecretVault.ps1 -VaultName "MyVault"
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName
)

Process {
    try {
        Unregister-SecretVault -Name $VaultName -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; VaultName = $VaultName; Message = "Vault '$VaultName' unregistered" }
    }
    catch { throw }
}
