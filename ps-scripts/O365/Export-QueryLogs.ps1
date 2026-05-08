#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Exports query logs
.DESCRIPTION
    Exports query logs for a user in the tenant.
.PARAMETER LoginName
    Login name of the user whose query logs to export
.PARAMETER OutputFolder
    Target folder where the CSV file is generated
.PARAMETER StartTime
    Point in time to export logs from
.EXAMPLE
    PS> ./Export-QueryLogs.ps1 -LoginName "user@contoso.com" -OutputFolder "C:\Exports"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder,
    [datetime]$StartTime
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; LoginName = $LoginName; OutputFolder = $OutputFolder }
        if (($null -ne $StartTime) -and ($StartTime.Year -gt 2018)) { $cmdArgs.Add('StartTime', $StartTime) }
        Export-SPOQueryLogs @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Query logs exported for '$LoginName' to '$OutputFolder'" }
    }
    catch { throw }
}