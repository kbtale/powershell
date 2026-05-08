#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Invokes migration encrypt upload submit
.DESCRIPTION
    Encrypts, uploads, and submits a migration package.
.PARAMETER PackageId
    Migration package ID
.PARAMETER TargetWebUrl
    Target SharePoint web URL
.EXAMPLE
    PS> ./Invoke-MigrationEncryptUploadSubmit.ps1 -PackageId "guid" -TargetWebUrl "https://contoso.sharepoint.com/sites/target"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][guid]$PackageId, [Parameter(Mandatory = $true)][string]$TargetWebUrl)
Process {
    try {
        $result = Invoke-SPOMigrationEncryptUploadSubmit -PackageId $PackageId -TargetWebUrl $TargetWebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
