#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Registers a new secret vault
.DESCRIPTION
    Registers a SecretManagement extension vault module for the current user.
.PARAMETER VaultName
    Name of the new vault
.PARAMETER Description
    Optional description for the vault
.PARAMETER DefaultVault
    Set the new vault as the default vault
.PARAMETER OverwriteExistingVault
    Overwrite an existing registered vault with the same name
.EXAMPLE
    PS> ./Register-PSSMSecretVault.ps1 -VaultName "MyVault"
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName,

    [string]$Description,
    [switch]$DefaultVault,
    [switch]$OverwriteExistingVault
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; ModuleName = 'Microsoft.PowerShell.SecretStore'; Name = $VaultName; AllowClobber = $OverwriteExistingVault; DefaultVault = $DefaultVault; Confirm = $false; PassThru = $null }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        $result = Register-SecretVault @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
