#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Retrieves secret metadata from registered vaults
.DESCRIPTION
    Finds and returns metadata information about secrets in registered vaults.
.PARAMETER SecretName
    Name of the secret to query (use * for all)
.PARAMETER VaultName
    Name of the vault to search
.PARAMETER StorePassword
    Password to unlock the SecretStore if required
.EXAMPLE
    PS> ./Get-PSSMSecretInfo.ps1 -SecretName "*" -VaultName "MyVault"
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SecretName,

    [securestring]$StorePassword,
    [string]$VaultName
)

Process {
    try {
        if ($null -ne $StorePassword) { Unlock-SecretStore -Password $StorePassword -ErrorAction Stop }
        if ([System.String]::IsNullOrWhiteSpace($SecretName)) { $SecretName = '*' }
        $cmdArgs = @{ ErrorAction = 'Stop'; Name = $SecretName }
        if ($PSBoundParameters.ContainsKey('VaultName')) { $cmdArgs.Add('Vault', $VaultName) }
        $result = Get-SecretInfo @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
