#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves the installed PowerCLI version
.DESCRIPTION
    Gets the version of the installed VMware PowerCLI module.
.EXAMPLE
    PS> ./Get-PowerCLIVersion.ps1
.CATEGORY VMware
#>
[CmdletBinding()]
Param()
Process {
    try {
        $result = Get-Module -Name VMware.PowerCLI -ErrorAction Stop | Format-List
        Write-Output $result
    }
    catch { throw }
}