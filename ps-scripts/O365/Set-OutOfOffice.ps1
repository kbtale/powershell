#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Configures Automatic Replies (Out of Office) for mailboxes
.DESCRIPTION
    Enables, disables, or schedules Automatic Replies for one or more mailboxes in Exchange Online. Supports internal and external messages with scheduling options.
.PARAMETER MailboxIds
    Aliases, Display names, Distinguished names, SamAccountNames, Guids or user principal names of the mailboxes
.PARAMETER InternalText
    Automatic Replies message sent to internal senders within the organization
.PARAMETER AutoReplyType
    Specifies who receives Automatic Replies: All, Only contact list members, or Internal only
.PARAMETER ExternalText
    Automatic Replies message sent to external senders outside the organization
.PARAMETER StartDate
    Start date for scheduled Automatic Replies. The text StartDate in messages will be replaced by this date.
.PARAMETER EndDate
    End date for scheduled Automatic Replies. The text EndDate in messages will be replaced by this date.
.EXAMPLE
    PS> ./Set-OutOfOffice.ps1 -MailboxIds "user@domain.com" -InternalText "I am out of office" -ExternalText "Out of office"
.EXAMPLE
    PS> ./Set-OutOfOffice.ps1 -MailboxIds "user@domain.com" -InternalText "Away" -StartDate "2024-07-01" -EndDate "2024-07-10"
.EXAMPLE
    PS> ./Set-OutOfOffice.ps1 -MailboxIds "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "DisableAutoReply")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "DisableAutoReply")]
    [Parameter(Mandatory = $true, ParameterSetName = "EnableAutoReply")]
    [Parameter(Mandatory = $true, ParameterSetName = "ScheduleAutoReply")]
    [string[]]$MailboxIds,
    [Parameter(Mandatory = $true, ParameterSetName = "EnableAutoReply")]
    [Parameter(Mandatory = $true, ParameterSetName = "ScheduleAutoReply")]
    [string]$InternalText,
    [Parameter(ParameterSetName = "EnableAutoReply")]
    [Parameter(ParameterSetName = "ScheduleAutoReply")]
    [ValidateSet("All", "Only contact list members", "Internal only")]
    [string]$AutoReplyType = "All",
    [Parameter(ParameterSetName = "EnableAutoReply")]
    [Parameter(ParameterSetName = "ScheduleAutoReply")]
    [string]$ExternalText,
    [Parameter(Mandatory = $true, ParameterSetName = "ScheduleAutoReply")]
    [datetime]$StartDate,
    [Parameter(Mandatory = $true, ParameterSetName = "ScheduleAutoReply")]
    [datetime]$EndDate
)

Process {
    try {
        [string[]]$resultMessage = @()
        [string]$msg = "Mailbox {0} "
        [string]$replyType = 'All'

        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Confirm' = $false}

        if ($PSCmdlet.ParameterSetName -eq "DisableAutoReply") {
            $cmdArgs.Add('AutoReplyState', 'Disabled')
            $msg += "disabled"
        }
        else {
            if ($AutoReplyType -eq 'Only contact list members') {
                $replyType = 'Known'
            }
            if ($AutoReplyType -eq 'Internal only') {
                $replyType = 'None'
            }
            if ($PSCmdlet.ParameterSetName -eq "ScheduleAutoReply") {
                if (-not [System.String]::IsNullOrWhiteSpace($InternalText)) {
                    $InternalText = $InternalText.Replace("StartDate", $StartDate.ToShortDateString()).Replace("EndDate", $EndDate.ToShortDateString())
                }
                if ($replyType -ne 'None') {
                    if (-not [System.String]::IsNullOrWhiteSpace($ExternalText)) {
                        $ExternalText = $ExternalText.Replace("StartDate", $StartDate.ToShortDateString()).Replace("EndDate", $EndDate.ToShortDateString())
                    }
                }
                if ($StartDate.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()) {
                    $StartDate = [DateTime]::Now
                }
                if (($null -eq $EndDate) -or ($EndDate.Year -lt 2020)) {
                    $EndDate = $StartDate
                }
                if ($EndDate.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()) {
                    $EndDate = $StartDate.AddDays(1)
                }
            }
            if ([System.String]::IsNullOrWhiteSpace($ExternalText)) {
                $ExternalText = $InternalText
            }
            $cmdArgs.Add('ExternalAudience', $replyType)
            $cmdArgs.Add('InternalMessage', $InternalText)
            $cmdArgs.Add('ExternalMessage', $ExternalText)
            if ($PSCmdlet.ParameterSetName -eq "ScheduleAutoReply") {
                $cmdArgs.Add('AutoReplyState', 'Scheduled')
                $cmdArgs.Add('EndTime', $EndDate)
                $cmdArgs.Add('StartTime', $StartDate)
                $msg += "scheduled"
            }
            else {
                $cmdArgs.Add('AutoReplyState', 'Enabled')
                $msg += "enabled"
            }
        }

        $output = @()
        foreach ($item in $MailboxIds) {
            try {
                $box = Get-Mailbox -Identity $item -ErrorAction Stop
                if ($null -ne $box) {
                    try {
                        $null = Set-MailboxAutoReplyConfiguration @cmdArgs -Identity $box.UserPrincipalName -ErrorAction Stop
                        $resultMessage += [System.String]::Format($msg, $box.UserPrincipalName)
                    }
                    catch {
                        Write-Output "Error occurred at set Mailbox $($item)"
                    }
                }
            }
            catch {
                Write-Output "Error occurred at get Mailbox $($item)"
            }
        }

        $output = foreach ($msgItem in $resultMessage) {
            [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Mailbox   = $msgItem
            }
        }
        if ($output.Count -gt 0) {
            Write-Output $output
        }
    }
    catch { throw }
}
