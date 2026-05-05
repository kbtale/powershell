#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits mailbox message rules (Inbox rules)

.DESCRIPTION
    Retrieves properties for a specifies message rule or lists all rules within a specifies mail folder (typically Inbox).

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the mail folder (e.g., 'inbox').

.PARAMETER RuleId
    Optional. Specifies the ID of a specific rule to retrieve. If omitted, all rules are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMailFolderMessageRule.ps1 -Identity "user@example.com" -MailFolderId "inbox"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [string]$RuleId
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'ErrorAction'  = 'Stop'
        }

        if ($RuleId) {
            $params.Add('MessageRuleId', $RuleId)
        }
        else {
            $params.Add('All', $true)
        }

        $rules = Get-MgUserMailFolderMessageRule @params
        
        $results = foreach ($r in $rules) {
            [PSCustomObject]@{
                DisplayName = $r.DisplayName
                IsEnabled   = $r.IsEnabled
                Sequence    = $r.Sequence
                Id          = $r.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Sequence)
    }
    catch {
        throw
    }
}
