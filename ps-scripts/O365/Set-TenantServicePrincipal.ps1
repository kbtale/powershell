#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Enables or disables the service principal
.DESCRIPTION
    Enables or disables the tenant's SharePoint Online Client service principal.
.PARAMETER Disable
    Set to $true to disable, $false to enable the service principal
.EXAMPLE
    PS> ./Set-TenantServicePrincipal.ps1 -Disable $false
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [bool]$Disable
)

Process {
    try {
        if ($Disable -eq $false) {
            $result = Enable-SPOTenantServicePrincipal -Confirm:$false -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Disable-SPOTenantServicePrincipal -Confirm:$false -ErrorAction Stop | Select-Object *
        }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}