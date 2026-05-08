#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Query-format list of mailboxes
.DESCRIPTION
    Returns Exchange Online mailboxes as Value/DisplayValue pairs for use in dropdown selectors. Supports filtering for inactive and resource mailboxes.
.PARAMETER InactiveMailboxOnly
    Include only inactive mailboxes in the results
.PARAMETER IncludeInactiveMailbox
    Include inactive mailboxes in the results
.PARAMETER ExcludeResources
    Exclude resource mailboxes from the results
.EXAMPLE
    PS> ./Get-Mailboxes-Query.ps1
.EXAMPLE
    PS> ./Get-Mailboxes-Query.ps1 -InactiveMailboxOnly
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
        [string[]]$Properties = @('PrimarySmtpAddress','UserPrincipalName','DisplayName','WindowsEmailAddress','IsInactiveMailbox','IsResource')

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
            Write-Output "No Mailboxes found"
            return
        }

        if ($ExcludeResources) {
            $boxes = $boxes | Where-Object -Property IsResource -EQ $false
        }

        foreach ($itm in $boxes) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $itm.UserPrincipalName
                DisplayValue = $itm.DisplayName
            }
        }
    }
    catch { throw }
}
