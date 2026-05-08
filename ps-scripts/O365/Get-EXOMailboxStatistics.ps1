#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets mailbox statistics for a specified mailbox
.DESCRIPTION
    Retrieves mailbox statistics including item counts, sizes, and last logon times using the EXO V2 module.
.PARAMETER Identity
    Name, Alias or SamAccountName of the mailbox
.PARAMETER Archive
    Return mailbox statistics for the archive mailbox associated with the specified mailbox
.PARAMETER IncludeSoftDeletedRecipients
    Include soft-deleted mailboxes in the results
.PARAMETER PropertySet
    Logical grouping of properties to retrieve
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-EXOMailboxStatistics.ps1 -Identity "user@domain.com"
.EXAMPLE
    PS> ./Get-EXOMailboxStatistics.ps1 -Identity "user@domain.com" -Archive
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [switch]$Archive,
    [switch]$IncludeSoftDeletedRecipients,
    [ValidateSet('All','Minimum')]
    [string]$PropertySet = 'Minimum',
    [ValidateSet('*','DisplayName','DeletedItemCount','ItemCount','TotalDeletedItemSize','TotalItemSize','LastLogonTime','LastLogoffTime','SystemMessageSizeWarningQuota')]
    [string[]]$Properties = @('DisplayName','DeletedItemCount','ItemCount','TotalDeletedItemSize','TotalItemSize')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity; 'Archive' = $Archive; 'PropertySet' = $PropertySet; 'IncludeSoftDeletedRecipients' = $IncludeSoftDeletedRecipients}

        $result = Get-EXOMailboxStatistics @cmdArgs | Select-Object $Properties
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No mailbox statistics found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
