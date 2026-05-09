#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Adds or updates a secret in a vault
.DESCRIPTION
    Adds a secret to a SecretManagement registered vault, with optional overwrite protection.
.PARAMETER SecretName
    Name of the secret
.PARAMETER SecretValue
    Value of the secret (secure string)
.PARAMETER VaultName
    Name of the vault to store the secret in
.PARAMETER OverwriteExistingSecret
    Update the secret if it already exists
.PARAMETER StorePassword
    Password to unlock the SecretStore if required
.EXAMPLE
    PS> ./Set-PSSMSecret.ps1 -SecretName "MyApiKey" -SecretValue (Read-Host -AsSecureString)
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SecretName,

    [Parameter(Mandatory = $true)]
    [securestring]$SecretValue,

    [securestring]$StorePassword,
    [string]$VaultName,
    [switch]$OverwriteExistingSecret
)

Process {
    try {
        if ($null -ne $StorePassword) { Unlock-SecretStore -Password $StorePassword -ErrorAction Stop }
        $cmdArgs = @{ ErrorAction = 'Stop'; Name = $SecretName; Secret = $SecretValue; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('VaultName')) { $cmdArgs.Add('Vault', $VaultName) }
        if (-not $OverwriteExistingSecret) { $cmdArgs.Add('NoClobber', $true) }
        $null = Set-Secret @cmdArgs -ErrorAction Stop
        $sec = Get-Secret -Name $SecretName -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; SecretName = $SecretName; Message = "Secret '$SecretName' stored" }
    }
    catch { throw }
}
