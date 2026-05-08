#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Query-format list of mailboxes
.DESCRIPTION
    Returns Exchange Online mailboxes as Value/DisplayValue pairs for use in dropdown selectors using the EXO V2 module.
.PARAMETER Archive
    Returns only mailboxes that have an archive mailbox
.PARAMETER InactiveMailboxOnly
    Returns only inactive mailboxes
.PARAMETER IncludeInactiveMailbox
    Include inactive mailboxes in the results
.PARAMETER SoftDeletedMailbox
    Include soft-deleted mailboxes in the results
.EXAMPLE
    PS> ./Get-EXOMailboxes-Query.ps1
.EXAMPLE
    PS> ./Get-EXOMailboxes-Query.ps1 -Archive
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$Archive,
    [switch]$InactiveMailboxOnly,
    [switch]$IncludeInactiveMailbox,
    [switch]$SoftDeletedMailbox
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Archive' = $Archive; 'InactiveMailboxOnly' = $InactiveMailboxOnly; 'IncludeInactiveMailbox' = $IncludeInactiveMailbox; 'SoftDeletedMailbox' = $SoftDeletedMailbox}

        $boxes = Get-EXOMailbox @cmdArgs | Select-Object DisplayName, Name | Sort-Object DisplayName

        if ($null -eq $boxes -or $boxes.Count -eq 0) {
            Write-Output "No mailboxes found"
            return
        }

        foreach ($itm in $boxes) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $itm.Name
                DisplayValue = $itm.DisplayName
            }
        }
    }
    catch { throw }
}
