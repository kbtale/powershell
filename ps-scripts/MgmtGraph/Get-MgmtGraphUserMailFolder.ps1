#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits user mail folders

.DESCRIPTION
    Retrieves properties for a specifies mail folder or lists all root mail folders in a user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Optional. Specifies the ID of a specific mail folder to retrieve. If omitted, all root folders are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMailFolder.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$MailFolderId
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'ErrorAction' = 'Stop'
        }

        if ($MailFolderId) {
            $params.Add('MailFolderId', $MailFolderId)
        }
        else {
            $params.Add('All', $true)
        }

        $folders = Get-MgUserMailFolder @params
        
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
