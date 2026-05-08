#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Lists mailboxes
.DESCRIPTION
    Retrieves mailboxes from Exchange Online with optional filters for inactive and resource mailboxes.
.PARAMETER InactiveMailboxOnly
    Include only inactive mailboxes
.PARAMETER IncludeInactiveMailbox
    Include inactive mailboxes in results
.PARAMETER ExcludeResources
    Exclude resource mailboxes
.EXAMPLE
    PS> ./Get-Mailbox.ps1 -IncludeInactiveMailbox
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
        if ($InactiveMailboxOnly) {
            $boxes = Get-Mailbox -InactiveMailboxOnly -SortBy DisplayName -ErrorAction Stop
        }
        elseif ($IncludeInactiveMailbox) {
            $boxes = Get-Mailbox -IncludeInactiveMailbox -SortBy DisplayName -ErrorAction Stop
        }
        else {
            $boxes = Get-Mailbox -SortBy DisplayName -ErrorAction Stop
        }

        $boxes = $boxes | Select-Object ArchiveStatus, UserPrincipalName, DisplayName, WindowsEmailAddress, IsInactiveMailbox, IsResource

        if ($ExcludeResources) {
            $boxes = $boxes | Where-Object -Property IsResource -EQ $false
        }

        if ($null -eq $boxes -or $boxes.Count -eq 0) {
            Write-Output "No mailboxes found"
            return
        }

        foreach ($box in $boxes) {
            $box | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
