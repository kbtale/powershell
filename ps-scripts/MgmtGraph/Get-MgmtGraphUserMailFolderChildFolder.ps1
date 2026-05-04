#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits child folders within a specifies user mail folder

.DESCRIPTION
    Retrieves properties for a specifies child folder or lists all child folders within a parent mail folder in a user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the parent mail folder.

.PARAMETER ChildFolderId
    Optional. Specifies the ID of a specific child folder to retrieve. If omitted, all child folders are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMailFolderChildFolder.ps1 -Identity "user@example.com" -MailFolderId "inbox"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [string]$ChildFolderId
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'ErrorAction'  = 'Stop'
        }

        if ($ChildFolderId) {
            $params.Add('MailFolderId1', $ChildFolderId)
        }
        else {
            $params.Add('All', $true)
        }

        $folders = Get-MgUserMailFolderChildFolder @params
        
        $results = foreach ($f in $folders) {
            [PSCustomObject]@{
                DisplayName       = $f.DisplayName
                Id                = $f.Id
                ChildFolderCount  = $f.ChildFolderCount
                TotalItemCount    = $f.TotalItemCount
                UnreadItemCount   = $f.UnreadItemCount
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
