#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets user's OneDrive location
.DESCRIPTION
    Returns the user principal name, current location, OneDrive URL, and site ID.
.PARAMETER UserPrincipalName
    User principal name to look up
.EXAMPLE
    PS> ./Get-UserOneDriveLocation.ps1 -UserPrincipalName "user@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName
)

Process {
    try {
        $result = Get-SPOUserOneDriveLocation -UserPrincipalName $UserPrincipalName -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}