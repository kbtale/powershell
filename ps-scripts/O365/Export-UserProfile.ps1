#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Exports user profile data
.DESCRIPTION
    Exports user profile data to a CSV file.
.PARAMETER LoginName
    Login name of the user whose data is exported
.PARAMETER OutputFolder
    Output folder location where the CSV file is created
.EXAMPLE
    PS> ./Export-UserProfile.ps1 -LoginName "user@contoso.com" -OutputFolder "C:\Exports"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; LoginName = $LoginName; OutputFolder = $OutputFolder }
        Export-SPOUserProfile @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User profile exported for '$LoginName' to '$OutputFolder'" }
    }
    catch { throw }
}