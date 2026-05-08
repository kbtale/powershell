#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: HTML report of resource mailboxes
.DESCRIPTION
    Generates an HTML report of all resource mailboxes in Exchange Online.
.EXAMPLE
    PS> ./Get-Resource-Html.ps1 | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        [string[]]$Properties = @('Name','IsMailboxEnabled','ProhibitSendQuota','RecipientLimits','IsShared','Database','ExchangeUserAccountControl','ExternalOofOptions')
        $res = Get-Mailbox -SortBy DisplayName -ErrorAction Stop | Where-Object -Property IsResource -EQ $true | Select-Object $Properties

        if ($null -eq $res -or $res.Count -eq 0) {
            Write-Output "No resources found"
            return
        }

        Write-Output ($res | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
