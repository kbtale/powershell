#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Submits a migration job
.DESCRIPTION
    Submits a migration package for processing.
.PARAMETER PackageId
    Migration package ID
.PARAMETER TargetWebUrl
    Target SharePoint web URL
.EXAMPLE
    PS> ./Submit-MigrationJob.ps1 -PackageId "guid" -TargetWebUrl "https://contoso.sharepoint.com/sites/target"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [guid]$PackageId,
    [Parameter(Mandatory = $true)]
    [string]$TargetWebUrl
)

Process {
    try {
        $result = Submit-SPOMigrationJob -PackageId $PackageId -TargetWebUrl $TargetWebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
