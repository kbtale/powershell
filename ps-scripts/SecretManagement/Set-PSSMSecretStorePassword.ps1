#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Changes the SecretStore password
.DESCRIPTION
    Replaces the current SecretStore password with a new one.
.PARAMETER CurrentStorePassword
    Current password to access the SecretStore
.PARAMETER NewStorePassword
    New password to access the SecretStore
.EXAMPLE
    PS> ./Set-PSSMSecretStorePassword.ps1 -CurrentStorePassword (Read-Host -AsSecureString) -NewStorePassword (Read-Host -AsSecureString)
.CATEGORY SecretManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [securestring]$CurrentStorePassword,

    [Parameter(Mandatory = $true)]
    [securestring]$NewStorePassword
)

Process {
    try {
        $result = Set-SecretStorePassword -NewPassword $NewStorePassword -Password $CurrentStorePassword -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
