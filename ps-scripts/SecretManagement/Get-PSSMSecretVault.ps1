#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
.SYNOPSIS
    SecretManagement: Retrieves registered vault information
.DESCRIPTION
    Finds and returns information about registered secret vaults.
.PARAMETER VaultName
    Optional name of a specific vault to retrieve
.EXAMPLE
    PS> ./Get-PSSMSecretVault.ps1
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [string]$VaultName
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('VaultName')) { $cmdArgs.Add('Name', $VaultName) }
        $result = Get-SecretVault @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
