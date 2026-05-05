#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Provisions a new child mail folder

.DESCRIPTION
    Creates a new mail folder within a specifies parent mail folder in a user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the parent mail folder.

.PARAMETER DisplayName
    Specifies the display name for the new child folder.

.PARAMETER Hidden
    Optional. If set to $true, the child folder will be hidden from the user interface.

.EXAMPLE
    PS> ./New-MgmtGraphUserMailFolderChildFolder.ps1 -Identity "user@example.com" -MailFolderId "inbox" -DisplayName "SubFolder"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [switch]$Hidden
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'DisplayName'  = $DisplayName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        if ($Hidden) { $params.Add('IsHidden', $true) }

        $folder = New-MgUserMailFolderChildFolder @params
        
        $result = [PSCustomObject]@{
            UserId      = $Identity
            ParentId    = $MailFolderId
            DisplayName = $DisplayName
            Id          = $folder.Id
            Status      = "ChildFolderCreated"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
