#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Gets resource mailbox properties
.DESCRIPTION
    Retrieves properties of a resource mailbox from Exchange Online, including calendar processing settings.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-ResourceProperties.ps1 -MailboxId "ConfRoom1@domain.com"
.EXAMPLE
    PS> ./Get-ResourceProperties.ps1 -MailboxId "ConfRoom1@domain.com" -Properties '*'
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [ValidateSet('*','DisplayName','WindowsEmailAddress','ResourceCapacity','AccountDisabled','IsMailboxEnabled','DistinguishedName','Alias','Guid','SamAccountName')]
    [string[]]$Properties = @('DisplayName','WindowsEmailAddress','ResourceCapacity','AccountDisabled','IsMailboxEnabled','DistinguishedName','Alias','Guid','SamAccountName')
)

Process {
    try {
        [string[]]$calProperties = @('AllBookInPolicy','AllowRecurringMeetings','BookingWindowInDays','EnforceSchedulingHorizon','MaximumDurationInMinutes','ScheduleOnlyDuringWorkHours')
        $res = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object $Properties

        if ($null -eq $res) {
            throw "Resource $($MailboxId) not found"
        }

        $calResult = Get-CalendarProcessing -Identity $MailboxId -ErrorAction Stop | Select-Object $calProperties
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        $res | Add-Member -NotePropertyName Timestamp -NotePropertyValue $ts -PassThru -Force
        Write-Output $res
        $calResult | Add-Member -NotePropertyName Timestamp -NotePropertyValue $ts -PassThru -Force
        Write-Output $calResult
    }
    catch { throw }
}
