#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a theme
.DESCRIPTION
    Deletes a custom tenant theme.
.PARAMETER Name
    Name of the theme to remove
.EXAMPLE
    PS> ./Remove-Theme.ps1 -Name "MyCustomTheme"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Name
)

Process {
    try {
        Remove-SPOTheme -Name $Name -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Theme '$Name' removed" }
    }
    catch { throw }
}
