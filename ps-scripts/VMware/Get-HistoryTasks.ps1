#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves historical task information
.DESCRIPTION
    Retrieves completed tasks from the task history going back a specified time period.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER MonthsAgo
    Number of months back to search
.PARAMETER DaysAgo
    Number of days back to search
.PARAMETER HoursAgo
    Number of hours back to search
.PARAMETER MinutesAgo
    Number of minutes back to search
.PARAMETER MaxResult
    Maximum number of tasks to retrieve
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-HistoryTasks.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -DaysAgo 7
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "Days ago")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Months ago")]
    [Parameter(Mandatory = $true, ParameterSetName = "Days ago")]
    [Parameter(Mandatory = $true, ParameterSetName = "Hours ago")]
    [Parameter(Mandatory = $true, ParameterSetName = "Minutes ago")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "Months ago")]
    [Parameter(Mandatory = $true, ParameterSetName = "Days ago")]
    [Parameter(Mandatory = $true, ParameterSetName = "Hours ago")]
    [Parameter(Mandatory = $true, ParameterSetName = "Minutes ago")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Months ago")]
    [int32]$MonthsAgo,
    [Parameter(Mandatory = $true, ParameterSetName = "Days ago")]
    [int32]$DaysAgo,
    [Parameter(Mandatory = $true, ParameterSetName = "Hours ago")]
    [int32]$HoursAgo,
    [Parameter(Mandatory = $true, ParameterSetName = "Minutes ago")]
    [int32]$MinutesAgo,
    [Parameter(ParameterSetName = "Months ago")]
    [Parameter(ParameterSetName = "Days ago")]
    [Parameter(ParameterSetName = "Hours ago")]
    [Parameter(ParameterSetName = "Minutes ago")]
    [ValidateRange(1, 100)]
    [int32]$MaxResult = 20,
    [Parameter(ParameterSetName = "Months ago")]
    [Parameter(ParameterSetName = "Days ago")]
    [Parameter(ParameterSetName = "Hours ago")]
    [Parameter(ParameterSetName = "Minutes ago")]
    [ValidateSet('*', 'EntityName', 'Description', 'State', 'Cancelled', 'StartTime', 'QueueTime', 'CompleteTime', 'Name', 'DescriptionId')]
    [string[]]$Properties = @('EntityName', 'Description', 'State', 'Cancelled', 'StartTime', 'QueueTime', 'CompleteTime', 'Name', 'DescriptionId')
)
Process {
    $tCollector = $null
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $sView = Get-View ServiceInstance -Server $vmServer
        $taskMgr = Get-View $sView.Content.TaskManager -Server $vmServer
        $tFilter = New-Object VMware.Vim.TaskFilterSpec
        $tFilter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
        $tFilter.Time.timeType = [vmware.vim.taskfilterspectimeoption]::startedTime
        switch ($PSCmdlet.ParameterSetName) {
            "Months ago" { $tFilter.Time.beginTime = (Get-Date).AddMonths(-$MonthsAgo) }
            "Days ago" { $tFilter.Time.beginTime = (Get-Date).AddDays(-$DaysAgo) }
            "Hours ago" { $tFilter.Time.beginTime = (Get-Date).AddHours(-$HoursAgo) }
            "Minutes ago" { $tFilter.Time.beginTime = (Get-Date).AddMinutes(-$MinutesAgo) }
        }
        $tCollector = Get-View ($taskMgr.CreateCollectorForTasks($tFilter))
        $null = $tCollector.RewindCollector
        $result = $tCollector.ReadNextTasks($MaxResult) | Select-Object $Properties | Sort-Object -Property StartTime -Descending
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally {
        if ($null -ne $tCollector) { $tCollector.DestroyCollector() }
        if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue }
    }
}