#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of app errors
.DESCRIPTION
    Generates an HTML report of application errors for a specified product.
.PARAMETER ProductID
    The application GUID
.PARAMETER StartTimeInUtc
    Start time in UTC to search for errors
.PARAMETER EndTimeInUtc
    End time in UTC to search for errors
.EXAMPLE
    PS> ./Get-AppErrors-Html.ps1 -ProductID "a1b2c3d4-1234-5678-90ab-cdef12345678"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ProductID,
    [datetime]$EndTimeInUtc,
    [datetime]$StartTimeInUtc
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; ProductID = $ProductID }
        if (($null -ne $EndTimeInUtc) -and ($EndTimeInUtc.Year -gt 2015)) { $cmdArgs.Add('EndTimeInUtc', $EndTimeInUtc) }
        if (($null -ne $StartTimeInUtc) -and ($StartTimeInUtc.Year -gt 2015)) { $cmdArgs.Add('StartTimeInUtc', $StartTimeInUtc) }
        $result = Get-SPOAppErrors @cmdArgs | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}