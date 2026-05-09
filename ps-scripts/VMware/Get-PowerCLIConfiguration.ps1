#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves the VMware PowerCLI configuration
.DESCRIPTION
    Retrieves PowerCLI proxy configuration and default server policy settings.
.PARAMETER Scope
    Scope: Session, User, or AllUsers
.EXAMPLE
    PS> ./Get-PowerCLIConfiguration.ps1 -Scope "User"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [ValidateSet("Session", "User", "AllUsers")]
    [string]$Scope
)
Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($Scope)) { $result = Get-PowerCLIConfiguration -ErrorAction Stop | Format-List }
        else { $result = Get-PowerCLIConfiguration -Scope $Scope -ErrorAction Stop | Format-List }
        Write-Output $result
    }
    catch { throw }
}