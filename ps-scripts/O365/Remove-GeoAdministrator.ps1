#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a geo administrator
.DESCRIPTION
    Removes a user or group from geo administrator role.
.PARAMETER UserPrincipalName
    UPN of the user to remove
.PARAMETER GroupAlias
    Alias of the group to remove
.EXAMPLE
    PS> ./Remove-GeoAdministrator.ps1 -UserPrincipalName "admin@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true, ParameterSetName = "Group")]
    [string]$GroupAlias
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "User") { Remove-SPOGeoAdministrator -UserPrincipalName $UserPrincipalName -ErrorAction Stop }
        else { Remove-SPOGeoAdministrator -GroupAlias $GroupAlias -ErrorAction Stop }
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Geo administrator removed" }
    }
    catch { throw }
}
