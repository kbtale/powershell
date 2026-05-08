#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes an external user
.DESCRIPTION
    Removes a collection of external users from the tenant.
.PARAMETER UniqueID
    ID that identifies the external user based on their Windows Live ID
.EXAMPLE
    PS> ./Remove-ExternalUser.ps1 -UniqueID "a1b2c3d4-1234-5678-90ab-cdef12345678"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UniqueID
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; UniqueID = $UniqueID; Confirm = $false }
        $result = Remove-SPOExternalUser @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}