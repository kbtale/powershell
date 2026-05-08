#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: HTML report of mailbox statistics
.DESCRIPTION
    Generates an HTML report of mailbox statistics for all mailboxes in Exchange Online, including item counts and quota information.
.PARAMETER Archive
    Return mailbox statistics for archive mailboxes associated with the specified mailboxes
.EXAMPLE
    PS> ./Get-MailboxStatistics-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MailboxStatistics-Html.ps1 -Archive | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$Archive
)

Process {
    try {
        [string[]]$Properties = @('DisplayName','ItemCount','TotalItemSize','DeletedItemCount','TotalDeletedItemSize','DatabaseIssueWarningQuota','DatabaseProhibitSendQuota','DatabaseProhibitSendReceiveQuota','IsArchiveMailbox','LastInteractionTime','IsValid')
        $boxes = Get-Mailbox -SortBy DisplayName -ErrorAction Stop
        if ($null -eq $boxes -or $boxes.Count -eq 0) {
            throw "Mailboxes not found"
        }
        $res = $boxes | Get-MailboxStatistics -Archive:$Archive -ErrorAction Stop | Select-Object $Properties

        if ($null -eq $res -or $res.Count -eq 0) {
            Write-Output "No mailbox statistics found"
            return
        }

        Write-Output ($res | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
