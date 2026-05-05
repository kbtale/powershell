#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits mailbox settings for a Microsoft Graph user

.DESCRIPTION
    Retrieves configuration details for a specifies user's primary mailbox, including regional formats (Date/Time) and time zone.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMailboxSetting.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $settings = Get-MgUserMailboxSetting -UserId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            UserIdentity    = $Identity
            DateFormat      = $settings.DateFormat
            TimeFormat      = $settings.TimeFormat
            TimeZone        = $settings.TimeZone
            UserPurpose     = $settings.UserPurpose
            ArchiveStatus   = $settings.ArchiveStatus
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
