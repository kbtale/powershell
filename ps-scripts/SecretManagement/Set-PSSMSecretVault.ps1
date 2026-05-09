#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
.SYNOPSIS
    SecretManagement: Sets the default secret vault
.DESCRIPTION
    Sets the provided vault as the default vault, or clears all defaults.
.PARAMETER VaultName
    Name of the vault to set as default
.PARAMETER ClearDefault
    Clear default status from all registered vaults
.EXAMPLE
    PS> ./Set-PSSMSecretVault.ps1 -VaultName "MyVault"
.CATEGORY SecretManagement
#>

[CmdletBinding(DefaultParameterSetName = "SetDefault")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "SetDefault")]
    [string]$VaultName,

    [Parameter(ParameterSetName = "ClearDefault")]
    [bool]$ClearDefault = $true
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "SetDefault") {
            $null = Set-SecretVaultDefault -Name $VaultName -Confirm:$false -ErrorAction Stop | Select-Object *
            $result = Get-SecretVault -Name $VaultName -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-SecretVault -ErrorAction Stop | Sort-Object Name
            Set-SecretVaultDefault -ClearDefault:$ClearDefault -Confirm:$false -ErrorAction Stop | Out-Null
        }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
