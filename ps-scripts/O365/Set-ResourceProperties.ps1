#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Sets resource mailbox properties
.DESCRIPTION
    Sets properties of a resource mailbox in Exchange Online, including calendar processing settings. Only parameters with values are applied.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource
.PARAMETER AccountDisabled
    Disable the account associated with the resource
.PARAMETER Alias
    Alias name of the resource
.PARAMETER DisplayName
    Display name of the resource
.PARAMETER ResourceCapacity
    Capacity of the resource
.PARAMETER WindowsEmailAddress
    Windows email address of the resource
.PARAMETER AllBookInPolicy
    Automatically approve in-policy requests from all users
.PARAMETER AllowRecurringMeetings
    Allow recurring meetings
.PARAMETER BookingWindowInDays
    Maximum number of days in advance that the resource can be reserved
.PARAMETER EnforceSchedulingHorizon
    Behavior of recurring meetings that extend beyond the BookingWindowInDays
.PARAMETER MaximumDurationInMinutes
    Duration in minutes for meeting requests
.PARAMETER ScheduleOnlyDuringWorkHours
    Allow meetings to be scheduled outside of working hours
.EXAMPLE
    PS> ./Set-ResourceProperties.ps1 -MailboxId "ConfRoom1@domain.com" -ResourceCapacity 20 -BookingWindowInDays 180
.EXAMPLE
    PS> ./Set-ResourceProperties.ps1 -MailboxId "ConfRoom1@domain.com" -AllBookInPolicy $false -AllowRecurringMeetings $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$AccountDisabled,
    [string]$Alias,
    [string]$DisplayName,
    [int]$ResourceCapacity,
    [string]$WindowsEmailAddress,
    [bool]$AllBookInPolicy,
    [bool]$AllowRecurringMeetings,
    [int]$BookingWindowInDays,
    [bool]$EnforceSchedulingHorizon,
    [int]$MaximumDurationInMinutes,
    [bool]$ScheduleOnlyDuringWorkHours
)

Process {
    try {
        [string[]]$Properties = @('AccountDisabled','Alias','DisplayName','ResourceCapacity','WindowsEmailAddress')
        [string[]]$calProperties = @('AllBookInPolicy','AllowRecurringMeetings','BookingWindowInDays','EnforceSchedulingHorizon','MaximumDurationInMinutes','ScheduleOnlyDuringWorkHours')

        $box = Get-Mailbox -Identity $MailboxId -ErrorAction Stop
        if ($null -eq $box) {
            throw "Resource $($MailboxId) not found"
        }

        if (-not [System.String]::IsNullOrWhiteSpace($Alias)) {
            $null = Set-Mailbox -Identity $MailboxId -Alias $Alias -ErrorAction Stop
        }
        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) {
            $null = Set-Mailbox -Identity $MailboxId -DisplayName $DisplayName -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('ResourceCapacity')) {
            $null = Set-Mailbox -Identity $MailboxId -ResourceCapacity $ResourceCapacity -ErrorAction Stop
        }
        if (-not [System.String]::IsNullOrWhiteSpace($WindowsEmailAddress)) {
            $null = Set-Mailbox -Identity $MailboxId -WindowsEmailAddress $WindowsEmailAddress -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('AllBookInPolicy')) {
            $null = Set-CalendarProcessing -Identity $MailboxId -AllBookInPolicy $AllBookInPolicy -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('AllowRecurringMeetings')) {
            $null = Set-CalendarProcessing -Identity $MailboxId -AllowRecurringMeetings $AllowRecurringMeetings -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('BookingWindowInDays')) {
            $null = Set-CalendarProcessing -Identity $MailboxId -BookingWindowInDays $BookingWindowInDays -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('EnforceSchedulingHorizon')) {
            $null = Set-CalendarProcessing -Identity $MailboxId -EnforceSchedulingHorizon $EnforceSchedulingHorizon -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('MaximumDurationInMinutes')) {
            $null = Set-CalendarProcessing -Identity $MailboxId -MaximumDurationInMinutes $MaximumDurationInMinutes -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('ScheduleOnlyDuringWorkHours')) {
            $null = Set-CalendarProcessing -Identity $MailboxId -ScheduleOnlyDuringWorkHours $ScheduleOnlyDuringWorkHours -ErrorAction Stop
        }
        if (-not $PSBoundParameters.ContainsKey('AccountDisabled')) {
            $AccountDisabled = $box.AccountDisabled
        }
        $null = Set-Mailbox -Identity $box.Name -AccountDisabled:$AccountDisabled -Confirm:$false -ErrorAction Stop

        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object $Properties
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue $ts -PassThru -Force
        Write-Output $result

        $calResult = Get-CalendarProcessing -Identity $MailboxId -ErrorAction Stop | Select-Object $calProperties
        $calResult | Add-Member -NotePropertyName Timestamp -NotePropertyValue $ts -PassThru -Force
        Write-Output $calResult
    }
    catch { throw }
}
