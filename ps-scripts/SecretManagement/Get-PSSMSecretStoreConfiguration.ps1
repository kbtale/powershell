#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.SecretStore

<#
.SYNOPSIS
    SecretManagement: Retrieves SecretStore configuration
.DESCRIPTION
    Returns the current SecretStore configuration settings.
.EXAMPLE
    PS> ./Get-PSSMSecretStoreConfiguration.ps1
.CATEGORY SecretManagement
#>

Process {
    try {
        $result = Get-SecretStoreConfiguration -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
