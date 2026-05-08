#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get the internal module version
.DESCRIPTION
    Returns the MicrosoftTeams internal module version information.
.EXAMPLE
    PS> ./Get-MSTCsInternalModuleVersion.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        $result = Get-CsInternalModuleVersion -ErrorAction Stop
        [PSCustomObject]@{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Version   = $result
        }
    }
    catch { throw }
}
