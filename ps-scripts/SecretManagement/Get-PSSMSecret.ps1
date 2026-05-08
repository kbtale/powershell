#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Retrieves a secret from a registered vault
.DESCRIPTION
    Finds and returns a secret by name from registered vaults. Supports optional vault specification and plain text output.
.PARAMETER SecretName
    Name of the secret to retrieve
.PARAMETER VaultName
    Name of the vault to search
.PARAMETER AsPlainText
    Return the secret as a plain text string
.PARAMETER StorePassword
    Password to unlock the SecretStore if required
.EXAMPLE
    PS> ./Get-PSSMSecret.ps1 -SecretName "MyApiKey"
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SecretName,

    [securestring]$StorePassword,
    [string]$VaultName,
    [switch]$AsPlainText
)

Process {
    try {
        if ($null -ne $StorePassword) { Unlock-SecretStore -Password $StorePassword -ErrorAction Stop }
        $cmdArgs = @{ ErrorAction = 'Stop'; Name = $SecretName; AsPlainText = $AsPlainText }
        if ($PSBoundParameters.ContainsKey('VaultName')) { $cmdArgs.Add('Vault', $VaultName) }
        $sec = Get-Secret @cmdArgs -ErrorAction Stop
        if ($null -ne $sec) { [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; SecretName = $SecretName; Value = $sec.ToString() } }
    }
    catch { throw }
}
