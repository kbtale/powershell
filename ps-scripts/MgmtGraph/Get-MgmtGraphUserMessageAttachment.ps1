#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits user message attachments

.DESCRIPTION
    Retrieves the list of attachments (Files or Items) for a specifies message in a user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MessageId
    Specifies the ID of the message to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMessageAttachment.ps1 -Identity "user@example.com" -MessageId "message-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MessageId
)

Process {
    try {
        $attachments = Get-MgUserMessageAttachment -UserId $Identity -MessageId $MessageId -All -ErrorAction Stop
        
        $results = foreach ($a in $attachments) {
            [PSCustomObject]@{
                Name        = $a.Name
                ContentType = $a.ContentType
                Size        = $a.Size
                Id          = $a.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
