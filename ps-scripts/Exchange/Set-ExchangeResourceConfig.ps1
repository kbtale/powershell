#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Modifies properties of a Resource Mailbox

.DESCRIPTION
    Updates administrative attributes and calendar processing settings for a Microsoft Exchange resource mailbox (Room or Equipment).

.PARAMETER Identity
    Specifies the Identity of the resource mailbox.

.PARAMETER DisplayName
    Optional. Specifies a new display name.

.PARAMETER Capacity
    Optional. Specifies the resource capacity.

.PARAMETER AllBookInPolicy
    Optional. Automatically approve in-policy requests from all users.

.PARAMETER AllowRecurringMeetings
    Optional. Allow recurring meetings to be scheduled.

.PARAMETER BookingWindowInDays
    Optional. Specifies the maximum number of days in advance the resource can be reserved.

.PARAMETER MaximumDurationInMinutes
    Optional. Specifies the maximum duration for a meeting request.

.PARAMETER ScheduleOnlyDuringWorkHours
    Optional. Allow meetings only during defined work hours.

.PARAMETER AccountDisabled
    Optional. Enables or disables the associated user account.

.EXAMPLE
    PS> ./Set-ExchangeResourceConfig.ps1 -Identity "Room 101" -Capacity 20 -AllowRecurringMeetings $true

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string]$DisplayName,
    [int]$Capacity,
    [bool]$AllBookInPolicy,
    [bool]$AllowRecurringMeetings,
    [int]$BookingWindowInDays,
    [int]$MaximumDurationInMinutes,
    [bool]$ScheduleOnlyDuringWorkHours,
    [bool]$AccountDisabled
)

Process {
    try {
        $mailboxParams = @{
            'Identity'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }
        if ($PSBoundParameters.ContainsKey('DisplayName')) { $mailboxParams.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('Capacity')) { $mailboxParams.Add('ResourceCapacity', $Capacity) }
        if ($PSBoundParameters.ContainsKey('AccountDisabled')) { $mailboxParams.Add('AccountDisabled', $AccountDisabled) }

        if ($mailboxParams.Count -gt 3) {
            Set-Mailbox @mailboxParams
        }

        $calParams = @{
            'Identity'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }
        if ($PSBoundParameters.ContainsKey('AllBookInPolicy')) { $calParams.Add('AllBookInPolicy', $AllBookInPolicy) }
        if ($PSBoundParameters.ContainsKey('AllowRecurringMeetings')) { $calParams.Add('AllowRecurringMeetings', $AllowRecurringMeetings) }
        if ($PSBoundParameters.ContainsKey('BookingWindowInDays')) { $calParams.Add('BookingWindowInDays', $BookingWindowInDays) }
        if ($PSBoundParameters.ContainsKey('MaximumDurationInMinutes')) { $calParams.Add('MaximumDurationInMinutes', $MaximumDurationInMinutes) }
        if ($PSBoundParameters.ContainsKey('ScheduleOnlyDuringWorkHours')) { $calParams.Add('ScheduleOnlyDuringWorkHours', $ScheduleOnlyDuringWorkHours) }

        if ($calParams.Count -gt 3) {
            Set-CalendarProcessing @calParams
        }

        $result = [PSCustomObject]@{
            Identity  = $Identity
            Action    = "ResourceConfigUpdated"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
