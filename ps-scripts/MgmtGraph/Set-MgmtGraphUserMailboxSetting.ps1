#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Updates mailbox settings for a Microsoft Graph user

.DESCRIPTION
    Updates regional and regional-specific configurations for a specifies user's primary mailbox, such as date formats, time formats, and time zone.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to update.

.PARAMETER DateFormat
    Optional. Specifies the preferred date format (e.g., "yyyy-MM-dd").

.PARAMETER TimeFormat
    Optional. Specifies the preferred time format (e.g., "HH:mm").

.PARAMETER TimeZone
    Optional. Specifies the preferred time zone string (e.g., "W. Europe Standard Time").

.EXAMPLE
    PS> ./Set-MgmtGraphUserMailboxSetting.ps1 -Identity "user@example.com" -TimeZone "UTC"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$DateFormat,

    [string]$TimeFormat,

    [string]$TimeZone
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('DateFormat')) { $params.Add('DateFormat', $DateFormat) }
        if ($PSBoundParameters.ContainsKey('TimeFormat')) { $params.Add('TimeFormat', $TimeFormat) }
        if ($PSBoundParameters.ContainsKey('TimeZone')) { $params.Add('TimeZone', $TimeZone) }

        if ($params.Count -gt 3) {
            Update-MgUserMailboxSetting @params
            
            $result = [PSCustomObject]@{
                UserIdentity = $Identity
                Action       = "UserMailboxSettingUpdated"
                Status       = "Success"
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for user mailbox settings."
        }
    }
    catch {
        throw
    }
}
