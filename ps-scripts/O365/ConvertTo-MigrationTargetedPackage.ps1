#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Creates a targeted migration package
.DESCRIPTION
    Converts a source package into a targeted migration package.
.PARAMETER TargetWebUrl
    Target SharePoint web URL
.PARAMETER SourceFilesPath
    Temporary path with XML source files
.PARAMETER SourcePackagePath
    Source package path
.PARAMETER TargetFilesPath
    Path for target output
.PARAMETER TargetPackagePath
    Target package output path
.PARAMETER Credential
    Optional target credentials
.EXAMPLE
    PS> ./ConvertTo-MigrationTargetedPackage.ps1 -TargetWebUrl "https://contoso.sharepoint.com/sites/target" -SourceFilesPath "C:\src" -SourcePackagePath "C:\src\package" -TargetFilesPath "C:\dst" -TargetPackagePath "C:\dst\package"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$TargetWebUrl,
    [Parameter(Mandatory = $true)]
    [string]$SourceFilesPath,
    [Parameter(Mandatory = $true)]
    [string]$SourcePackagePath,
    [Parameter(Mandatory = $true)]
    [string]$TargetFilesPath,
    [Parameter(Mandatory = $true)]
    [string]$TargetPackagePath,
    [pscredential]$Credential
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; TargetWebUrl = $TargetWebUrl; SourceFilesPath = $SourceFilesPath; SourcePackagePath = $SourcePackagePath; TargetFilesPath = $TargetFilesPath; TargetPackagePath = $TargetPackagePath }
        if ($null -ne $Credential) { $cmdArgs.Add('Credentials', $Credential) }
        $result = ConvertTo-SPOMigrationTargetedPackage @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
