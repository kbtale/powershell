#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets folder-level permissions in mailboxes
.DESCRIPTION
    Retrieves folder-level permissions for a specified mailbox folder using the EXO V2 module.
.PARAMETER Identity
    Name, Alias or SamAccountName of the mailbox
.PARAMETER FolderName
    The mailbox folder to view permissions for
.PARAMETER GroupMailbox
    Required to return Microsoft 365 Groups in the results
.PARAMETER User
    Filters results by the user granted permission to the mailbox folder (Name, Alias or Guid)
.EXAMPLE
    PS> ./Get-EXOMailboxFolderPermission.ps1 -Identity "user@domain.com" -FolderName "Inbox"
.EXAMPLE
    PS> ./Get-EXOMailboxFolderPermission.ps1 -Identity "user@domain.com" -FolderName "Calendar" -User "delegate@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [switch]$GroupMailbox,
    [string]$User
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = "$($Identity):\$($FolderName)"; 'GroupMailbox' = $GroupMailbox}

        if ($PSBoundParameters.ContainsKey('User')) {
            $cmdArgs.Add('User', $User)
        }

        $result = Get-EXOMailboxFolderPermission @cmdArgs | Select-Object *
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No folder permissions found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
