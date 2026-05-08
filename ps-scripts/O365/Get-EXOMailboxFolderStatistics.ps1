#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets folder statistics for a specified mailbox
.DESCRIPTION
    Retrieves folder-level statistics including item counts and sizes for a mailbox using the EXO V2 module.
.PARAMETER Identity
    Name, Alias or SamAccountName of the mailbox
.PARAMETER Folderscope
    Scope of the search by folder type
.PARAMETER Archive
    Return usage statistics of the archive mailbox associated with the mailbox
.PARAMETER IncludeOldestAndNewestItems
    Return dates of the oldest and newest items in each folder
.PARAMETER IncludeSoftDeletedRecipients
    Include soft-deleted mailboxes in the results
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-EXOMailboxFolderStatistics.ps1 -Identity "user@domain.com"
.EXAMPLE
    PS> ./Get-EXOMailboxFolderStatistics.ps1 -Identity "user@domain.com" -Folderscope "Inbox" -Archive
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [ValidateSet('All','Archive','Calendar','Clutter','Contacts','ConversationHistory','DeletedItems','Drafts','Inbox','Journal','JunkEmail','LegacyArchiveJournals','ManagedCustomFolder','NonIpmRoot','Notes','Outbox','Personal','RecoverableItems','RssSubscriptions','SentItems','SyncIssues','Tasks')]
    [string]$Folderscope = 'All',
    [switch]$Archive,
    [switch]$IncludeOldestAndNewestItems,
    [switch]$IncludeSoftDeletedRecipients,
    [ValidateSet('*','Name','LastModifiedTime','ItemsInFolder','DeletedItemsInFolder','FolderAndSubfolderSize','FolderSize','FolderType','FolderPath','Identity')]
    [string[]]$Properties = @('Name','LastModifiedTime','ItemsInFolder','DeletedItemsInFolder','FolderAndSubfolderSize','FolderType','FolderPath')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity; 'Folderscope' = $Folderscope; 'Archive' = $Archive; 'IncludeOldestAndNewestItems' = $IncludeOldestAndNewestItems; 'IncludeSoftDeletedRecipients' = $IncludeSoftDeletedRecipients}

        $result = Get-EXOMailboxFolderStatistics @cmdArgs | Select-Object $Properties
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No folder statistics found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
