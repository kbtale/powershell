#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes an SDN provider
.DESCRIPTION
    Unregisters a software defined network provider.
.PARAMETER Identity
    Name of the SDN provider to remove
.EXAMPLE
    PS> ./Remove-SdnProvider.ps1 -Identity "MyProvider"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        Remove-SPOSdnProvider -Identity $Identity -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "SDN provider '$Identity' removed" }
    }
    catch { throw }
}
