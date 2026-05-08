#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Creates a migration package
.DESCRIPTION
    Creates a new SharePoint migration package with metadata.
.PARAMETER SourceFilesPath
    Path to source files
.PARAMETER TargetFilesPath
    Path for target output
.EXAMPLE
    PS> ./New-MigrationPackage.ps1 -SourceFilesPath "C:\src" -TargetFilesPath "C:\dst"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SourceFilesPath,
    [Parameter(Mandatory = $true)]
    [string]$TargetFilesPath
)

Process {
    try {
        $result = New-SPOMigrationPackage -SourceFilesPath $SourceFilesPath -TargetFilesPath $TargetFilesPath -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
