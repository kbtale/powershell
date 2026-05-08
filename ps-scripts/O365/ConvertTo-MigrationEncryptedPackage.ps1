#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Creates an encrypted migration package
.DESCRIPTION
    Converts XML source files into an encrypted migration package.
.PARAMETER EncryptionParameters
    Encryption parameters (e.g., SHA384, SHA256)
.PARAMETER MigrationSourceLocations
    Migration source locations (for implicit source)
.PARAMETER SourceFilesPath
    Temporary path with XML source files (explicit source)
.PARAMETER SourcePackagePath
    Source package path (explicit source)
.PARAMETER TargetFilesPath
    Temporary path for target XML files
.PARAMETER TargetPackagePath
    Target package path for encrypted output
.PARAMETER NoLogFile
    Suppress log file generation
.EXAMPLE
    PS> ./ConvertTo-MigrationEncryptedPackage.ps1 -EncryptionParameters "SHA256" -MigrationSourceLocations "FileShare" -TargetFilesPath "C:\temp" -TargetPackagePath "C:\output"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "ImplicitSource")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ExplicitSource")]
    [Parameter(Mandatory = $true, ParameterSetName = "ImplicitSource")]
    [string]$EncryptionParameters,

    [Parameter(Mandatory = $true, ParameterSetName = "ImplicitSource")]
    [string]$MigrationSourceLocations,

    [Parameter(Mandatory = $true, ParameterSetName = "ExplicitSource")]
    [string]$SourceFilesPath,

    [Parameter(Mandatory = $true, ParameterSetName = "ExplicitSource")]
    [string]$SourcePackagePath,

    [Parameter(Mandatory = $true, ParameterSetName = "ExplicitSource")]
    [Parameter(Mandatory = $true, ParameterSetName = "ImplicitSource")]
    [string]$TargetFilesPath,

    [Parameter(Mandatory = $true, ParameterSetName = "ExplicitSource")]
    [Parameter(Mandatory = $true, ParameterSetName = "ImplicitSource")]
    [string]$TargetPackagePath,

    [Parameter(ParameterSetName = "ExplicitSource")]
    [Parameter(ParameterSetName = "ImplicitSource")]
    [switch]$NoLogFile
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; NoLogFile = $NoLogFile; EncryptionParameters = $EncryptionParameters; TargetFilesPath = $TargetFilesPath; TargetPackagePath = $TargetPackagePath }
        if ($PSCmdlet.ParameterSetName -eq "ImplicitSource") { $cmdArgs.Add('MigrationSourceLocations', $MigrationSourceLocations) }
        else { $cmdArgs.Add('SourceFilesPath', $SourceFilesPath); $cmdArgs.Add('SourcePackagePath', $SourcePackagePath) }
        $result = ConvertTo-SPOMigrationEncryptedPackage @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
