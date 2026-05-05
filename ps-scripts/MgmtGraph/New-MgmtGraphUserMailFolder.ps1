#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Provisions a new mail folder in a user's mailbox

.DESCRIPTION
    Creates a new mail folder within a specifies user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER DisplayName
    Specifies the display name for the new mail folder.

.PARAMETER Hidden
    Optional. If set to $true, the mail folder will be hidden from the user interface.

.EXAMPLE
    PS> ./New-MgmtGraphUserMailFolder.ps1 -Identity "user@example.com" -DisplayName "Project Archive"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [switch]$Hidden
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'DisplayName' = $DisplayName
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($Hidden) { $params.Add('IsHidden', $true) }

        $folder = New-MgUserMailFolder @params
        
        $result = [PSCustomObject]@{
            UserId      = $Identity
            DisplayName = $DisplayName
            Id          = $folder.Id
            Status      = "MailFolderCreated"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
