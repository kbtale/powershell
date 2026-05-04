#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits user inference classification overrides

.DESCRIPTION
    Retrieves the list of sender-based overrides for Focused Inbox for a specifies user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.EXAMPLE
    PS> ./Get-MgmtGraphUserInferenceClassificationOverride.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $overrides = Get-MgUserInferenceClassificationOverride -UserId $Identity -All -ErrorAction Stop
        
        $results = foreach ($o in $overrides) {
            [PSCustomObject]@{
                SenderName    = $o.SenderEmailAddress.Name
                SenderAddress = $o.SenderEmailAddress.Address
                ClassifyAs    = $o.ClassifyAs
                Id            = $o.Id
                Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object SenderName)
    }
    catch {
        throw
    }
}
