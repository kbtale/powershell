#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets migration package Azure source
.DESCRIPTION
    Configures the Azure source for a migration package.
.PARAMETER PackageId
    Migration package ID
.PARAMETER AzureBlobKey
    Azure blob storage key
.PARAMETER AzureBlobUri
    Azure blob storage URI
.EXAMPLE
    PS> ./Set-MigrationPackageAzureSource.ps1 -PackageId "guid" -AzureBlobKey "key" -AzureBlobUri "https://..."
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [guid]$PackageId,
    [Parameter(Mandatory = $true)]
    [string]$AzureBlobKey,
    [Parameter(Mandatory = $true)]
    [string]$AzureBlobUri
)

Process {
    try {
        $result = Set-SPOMigrationPackageAzureSource -PackageId $PackageId -AzureBlobKey $AzureBlobKey -AzureBlobUri $AzureBlobUri -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
