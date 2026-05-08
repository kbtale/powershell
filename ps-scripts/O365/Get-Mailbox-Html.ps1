#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: HTML report of mailboxes
.DESCRIPTION
    Generates an HTML report of mailboxes in Exchange Online, with optional filters for inactive and resource mailboxes.
.PARAMETER InactiveMailboxOnly
    Include only inactive mailboxes in the results
.PARAMETER IncludeInactiveMailbox
    Include inactive mailboxes in the results
.PARAMETER ExcludeResources
    Exclude resource mailboxes from the results
.EXAMPLE
    PS> ./Get-Mailbox-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-Mailbox-Html.ps1 -IncludeInactiveMailbox -ExcludeResources | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$InactiveMailboxOnly,
    [switch]$IncludeInactiveMailbox,
    [switch]$ExcludeResources
)

Process {
    try {
        [string[]]$Properties = @('DisplayName','WindowsEmailAddress','IsInactiveMailbox','IsResource','ArchiveStatus','UserPrincipalName')

        if ($InactiveMailboxOnly) {
            $boxes = Get-Mailbox -InactiveMailboxOnly -SortBy DisplayName -ErrorAction Stop | Select-Object $Properties
        }
        elseif ($IncludeInactiveMailbox) {
            $boxes = Get-Mailbox -IncludeInactiveMailbox -SortBy DisplayName -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $boxes = Get-Mailbox -SortBy DisplayName -ErrorAction Stop | Select-Object $Properties
        }

        if ($null -eq $boxes -or $boxes.Count -eq 0) {
            Write-Output "No mailboxes found"
            return
        }

        if ($ExcludeResources) {
            $boxes = $boxes | Where-Object -Property IsResource -EQ $false
        }

        Write-Output ($boxes | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
