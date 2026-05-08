#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Invoke internal PowerShell telemetry
.DESCRIPTION
    Invokes the internal PowerShell telemetry cmdlet for Microsoft Teams.
.EXAMPLE
    PS> ./Invoke-MSTCsInternalPSTelemetry.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        $result = Invoke-CsInternalPSTelemetry -ErrorAction Stop

        if ($null -eq $result) {
            Write-Output "No telemetry data returned"
            return
        }
        [PSCustomObject]@{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Result    = $result
        }
    }
    catch { throw }
}
