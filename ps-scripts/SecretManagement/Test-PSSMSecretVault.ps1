#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
.SYNOPSIS
    SecretManagement: Tests a secret vault
.DESCRIPTION
    Validates that a secret vault is accessible and functional.
.PARAMETER VaultName
    Name of the vault to test
.EXAMPLE
    PS> ./Test-PSSMSecretVault.ps1 -VaultName "MyVault"
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName
)

Process {
    try {
        $result = Test-SecretVault -Name $VaultName -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; VaultName = $VaultName; IsAvailable = $result }
    }
    catch { throw }
}
