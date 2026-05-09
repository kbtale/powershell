#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
.SYNOPSIS
    SecretManagement: Query returns registered vaults
.DESCRIPTION
    Returns registered secret vaults as Value/DisplayValue pairs for use in selection dialogs.
.EXAMPLE
    PS> ./Get-PSSMSecretVault-Query.ps1
.CATEGORY SecretManagement
#>

Process {
    try {
        $vaults = Get-SecretVault -ErrorAction Stop | Sort-Object Name
        foreach ($vault in $vaults) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $vault.Name; DisplayValue = $vault.Name }
        }
    }
    catch { throw }
}
