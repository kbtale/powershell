#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets migration job status
.DESCRIPTION
    Returns status of SharePoint migration jobs.
.PARAMETER PackageId
    Optional package ID filter
.EXAMPLE
    PS> ./Get-MigrationJobStatus.ps1 -PackageId "guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [guid]$PackageId
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('PackageId')) { $cmdArgs.Add('PackageId', $PackageId) }
        $result = Get-SPOMigrationJobStatus @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
