#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Resets the SecretStore
.DESCRIPTION
    Resets the SecretStore by deleting all secret data and configuring the store with default options.
.EXAMPLE
    PS> ./Reset-PSSMSecretStore.ps1
.CATEGORY SecretManagement
#>

Process {
    try {
        $result = Reset-SecretStore -PassThru -Force -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
