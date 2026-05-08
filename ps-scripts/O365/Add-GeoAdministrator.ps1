#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Adds a geo administrator
.DESCRIPTION
    Adds a user or group as a Geo Administrator for a multi-geo tenant.
.PARAMETER UserPrincipalName
    User principal name to add
.PARAMETER Group
    Group alias to add
.EXAMPLE
    PS> ./Add-GeoAdministrator.ps1 -UserPrincipalName "admin@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true, ParameterSetName = "Group")]
    [string]$Group
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSCmdlet.ParameterSetName -eq "User") {
            $result = Add-SPOGeoAdministrator -UserPrincipalName $UserPrincipalName @cmdArgs | Select-Object *
        }
        else { $result = Add-SPOGeoAdministrator -GroupAlias $Group @cmdArgs | Select-Object * }
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
