#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets MyAnalytics feature configuration for a user
.DESCRIPTION
    Views the availability and feature status of MyAnalytics for the specified user.
.PARAMETER Identity
    Name, Alias or SamAccountName of the user
.EXAMPLE
    PS> ./Get-EXOMyAnalyticsFeatureConfig.ps1 -Identity "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        $result = Get-MyAnalyticsFeatureConfig @cmdArgs
        if ($null -eq $result) {
            Write-Output "No MyAnalytics configuration found"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
