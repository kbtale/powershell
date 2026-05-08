#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a scheduled site design task
.DESCRIPTION
    Removes a previously scheduled site design application task.
.PARAMETER Identity
    ID of the scheduled site design task to remove
.EXAMPLE
    PS> ./Remove-SiteDesignTask.ps1 -Identity "a1b2c3d4-1234-5678-90ab-cdef12345678"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity }
        Remove-SPOSiteDesignTask @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site design task '$Identity' removed" }
    }
    catch { throw }
}