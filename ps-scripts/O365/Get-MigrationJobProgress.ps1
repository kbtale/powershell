#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets migration job progress
.DESCRIPTION
    Returns progress of a SharePoint migration job.
.PARAMETER PackageId
    The migration package ID
.EXAMPLE
    PS> ./Get-MigrationJobProgress.ps1 -PackageId "guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [guid]$PackageId
)

Process {
    try {
        $result = Get-SPOMigrationJobProgress -PackageId $PackageId -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
