#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets permissions on a mailbox
.DESCRIPTION
    Retrieves mailbox-level permissions for a specified mailbox using the EXO V2 module.
.PARAMETER Identity
    Name, Alias or SamAccountName of the mailbox
.PARAMETER Owner
    Returns the owner information for the mailbox
.PARAMETER SoftDeletedMailbox
    Return soft-deleted mailboxes in the results
.PARAMETER ResultSize
    Maximum number of results to return
.EXAMPLE
    PS> ./Get-EXOMailboxPermission.ps1 -Identity "user@domain.com"
.EXAMPLE
    PS> ./Get-EXOMailboxPermission.ps1 -Identity "user@domain.com" -Owner
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [switch]$Owner,
    [switch]$SoftDeletedMailbox,
    [int]$ResultSize = 1000
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'ResultSize' = $ResultSize; 'Owner' = $Owner; 'Identity' = $Identity; 'SoftDeletedMailbox' = $SoftDeletedMailbox}

        $result = Get-EXOMailboxPermission @cmdArgs
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No mailbox permissions found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
