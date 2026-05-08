#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of tenant log entries
.DESCRIPTION
    Generates an HTML report of SharePoint Online company logs.
.PARAMETER User
    Filter by log-on identity
.PARAMETER CorrelationId
    Filter by correlation ID
.PARAMETER Source
    Filter by component that logged the errors
.PARAMETER StartTime
    Start time to search for logs
.PARAMETER EndTime
    End time to search for logs
.PARAMETER MaxRows
    Maximum number of rows to return
.EXAMPLE
    PS> ./Get-TenantLogEntry-Html.ps1 -User "user@contoso.com" -MaxRows 500
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = 'User')]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'CorrelationId')]
    [string]$CorrelationId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Source')]
    [int]$Source,
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$User,
    [Parameter(ParameterSetName = 'CorrelationId')]
    [Parameter(ParameterSetName = 'Source')]
    [Parameter(ParameterSetName = 'User')]
    [datetime]$StartTime,
    [Parameter(ParameterSetName = 'CorrelationId')]
    [Parameter(ParameterSetName = 'Source')]
    [Parameter(ParameterSetName = 'User')]
    [datetime]$EndTime,
    [Parameter(ParameterSetName = 'CorrelationId')]
    [Parameter(ParameterSetName = 'Source')]
    [Parameter(ParameterSetName = 'User')]
    [ValidateRange(1, 5000)]
    [uint32]$MaxRows = 1000
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; MaxRows = $MaxRows }
        if (($null -ne $StartTime) -and ($StartTime.Year -gt 2010)) { $cmdArgs.Add('StartTimeInUtc', $StartTime) }
        if (($null -ne $EndTime) -and ($EndTime.Year -gt 2010)) { $cmdArgs.Add('EndTimeInUtc', $EndTime) }
        if ($PSCmdlet.ParameterSetName -eq 'CorrelationId') { $cmdArgs.Add('CorrelationId', $CorrelationId) }
        if ($PSCmdlet.ParameterSetName -eq 'Source') { $cmdArgs.Add('Source', $Source) }
        if ($PSCmdlet.ParameterSetName -eq 'User') { $cmdArgs.Add('User', $User) }
        $result = Get-SPOTenantLogEntry @cmdArgs | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}