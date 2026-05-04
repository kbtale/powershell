#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Retrieves detailed properties of a Resource Mailbox

.DESCRIPTION
    Gets administrative and scheduling properties for a specific Microsoft Exchange resource mailbox (Room or Equipment). Combines mailbox attributes and calendar processing settings.

.PARAMETER Identity
    Specifies the Identity of the resource mailbox.

.PARAMETER Properties
    Optional. Specifies an array of mailbox properties to retrieve.

.EXAMPLE
    PS> ./Get-ExchangeResourceInfo.ps1 -Identity "Room 101"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string[]]$Properties = @('DisplayName', 'Alias', 'PrimarySmtpAddress', 'ResourceCapacity', 'ResourceType', 'DistinguishedName', 'Guid')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        $mailbox = Get-Mailbox -Identity $Identity -ErrorAction Stop
        if ($mailbox.RecipientTypeDetails -notmatch 'Room|Equipment') {
            throw "The mailbox '$Identity' is not a resource mailbox (Current type: $($mailbox.RecipientTypeDetails))."
        }

        $cal = Get-CalendarProcessing -Identity $Identity -ErrorAction Stop

        $result = [PSCustomObject]@{
            DisplayName          = $mailbox.DisplayName
            Alias                = $mailbox.Alias
            PrimarySmtpAddress   = $mailbox.PrimarySmtpAddress
            ResourceCapacity     = $mailbox.ResourceCapacity
            ResourceType         = $mailbox.RecipientTypeDetails
            AutomateProcessing   = $cal.AutomateProcessing
            AllowRecurringMeetings = $cal.AllowRecurringMeetings
            BookingWindowInDays  = $cal.BookingWindowInDays
            MaximumDuration      = $cal.MaximumDurationInMinutes
            DistinguishedName    = $mailbox.DistinguishedName
            Guid                 = $mailbox.Guid
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
