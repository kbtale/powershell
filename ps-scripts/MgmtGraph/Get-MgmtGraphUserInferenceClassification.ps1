#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits user inference classification (Focused Inbox)

.DESCRIPTION
    Retrieves the relevance classification settings for a specifies user's mailbox, which determines Focused Inbox behavior.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.EXAMPLE
    PS> ./Get-MgmtGraphUserInferenceClassification.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $classification = Get-MgUserInferenceClassification -UserId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            UserId    = $Identity
            Id        = $classification.Id
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
