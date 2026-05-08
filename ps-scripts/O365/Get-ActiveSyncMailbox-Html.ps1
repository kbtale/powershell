#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: HTML report of ActiveSync mailbox settings
.DESCRIPTION
    Generates an HTML report of ActiveSync enabled/disabled state for all CAS mailboxes in Exchange Online.
.EXAMPLE
    PS> ./Get-ActiveSyncMailbox-Html.ps1 | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        [string[]]$Properties = @('ActiveSyncEnabled','DisplayName','PrimarySmtpAddress')
        $res = Get-CASMailbox -ErrorAction Stop | Select-Object $Properties | Sort-Object DisplayName

        if ($null -eq $res -or $res.Count -eq 0) {
            Write-Output "No mailboxes found"
            return
        }

        Write-Output ($res | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
