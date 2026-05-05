#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Provisions a new message in a user's mailbox

.DESCRIPTION
    Creates a new draft message in a specifies user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER Subject
    Specifies the subject line for the new message.

.PARAMETER Body
    Optional. Specifies the body content of the message.

.PARAMETER Categories
    Optional. Specifies an array of categories to associate with the message.

.EXAMPLE
    PS> ./New-MgmtGraphUserMessage.ps1 -Identity "user@example.com" -Subject "Meeting Request" -Body "Let's meet at 10 AM."

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$Subject,

    [string]$Body,

    [string[]]$Categories
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'Subject'     = $Subject
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($Body) {
            $params.Add('Body', @{
                ContentType = 'HTML'
                Content     = $Body
            })
        }
        if ($Categories) { $params.Add('Categories', $Categories) }

        $message = New-MgUserMessage @params
        
        $result = [PSCustomObject]@{
            UserId    = $Identity
            Subject   = $Subject
            Id        = $message.Id
            Status    = "MessageCreated"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
