#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get license report for change notification subscriptions
.DESCRIPTION
    Retrieves details of total change notification events for a specified period.
.PARAMETER Period
    Period of notification events (7, 30, 90, or 180 days)
.EXAMPLE
    PS> ./Get-MSTLicenseReport.ps1 -Period "30"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('7', '30', '90', '180')]
    [string]$Period
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Period' = $Period}

        $result = Get-LicenseReportForChangeNotificationSubscription @cmdArgs | Select-Object * | Sort-Object DisplayName

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No license report data found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
