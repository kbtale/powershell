#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Removes a secret from a vault
.DESCRIPTION
    Removes a secret from a specified registered extension vault.
.PARAMETER SecretName
    Name of the secret to remove
.PARAMETER VaultName
    Name of the vault containing the secret
.PARAMETER StorePassword
    Password to unlock the SecretStore if required
.EXAMPLE
    PS> ./Remove-PSSMSecret.ps1 -SecretName "MyApiKey" -VaultName "MyVault"
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SecretName,

    [Parameter(Mandatory = $true)]
    [string]$VaultName,

    [securestring]$StorePassword
)

Process {
    try {
        if ($null -ne $StorePassword) { Unlock-SecretStore -Password $StorePassword -ErrorAction Stop }
        $cmdArgs = @{ ErrorAction = 'Stop'; Name = $SecretName; Vault = $VaultName; Confirm = $false }
        Remove-Secret @cmdArgs -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; SecretName = $SecretName; VaultName = $VaultName; Message = "Secret '$SecretName' removed from vault '$VaultName'" }
    }
    catch { throw }
}
