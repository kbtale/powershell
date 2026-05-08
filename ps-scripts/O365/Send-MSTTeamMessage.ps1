#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Publish a message in a Microsoft Teams channel via webhook
.DESCRIPTION
    Sends a message to a Microsoft Teams channel using an incoming webhook URL. Supports title, color theme, activity title and subtitle.
.PARAMETER WebhookURL
    The URL of the incoming webhook, must start with "https://outlook.office.com/webhook/"
.PARAMETER Message
    The body of the message to publish on Teams
.PARAMETER Title
    The title of the message to publish on Teams
.PARAMETER MessageColor
    The color theme for the message (Orange, Green, Red)
.PARAMETER ActivityTitle
    The Activity title of the message
.PARAMETER ActivitySubtitle
    The Activity subtitle of the message
.EXAMPLE
    PS> ./Send-MSTTeamMessage.ps1 -WebhookURL "https://outlook.office.com/webhook/..." -Message "Build completed" -Title "CI/CD Notification"
.EXAMPLE
    PS> ./Send-MSTTeamMessage.ps1 -WebhookURL "https://outlook.office.com/webhook/..." -Message "Server alert" -MessageColor "Red" -ActivityTitle "Alert"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://outlook.office.com/webhook/')]
    [string]$WebhookURL,
    [Parameter(Mandatory = $true)]
    [string]$Message,
    [string]$Title,
    [ValidateSet('Orange', 'Green', 'Red')]
    [string]$MessageColor,
    [string]$ActivityTitle,
    [string]$ActivitySubtitle
)

Process {
    try {
        $body = [PSCustomObject]@{
            text       = $Message
            title      = $Title
            themeColor = if ($MessageColor -eq 'Orange') { '#FFA500' } elseif ($MessageColor -eq 'Green') { '#008000' } elseif ($MessageColor -eq 'Red') { '#FF0000' } else { '' }
        }

        $jsonBody = $body | ConvertTo-Json -Depth 3
        $null = Invoke-RestMethod -Uri $WebhookURL -Method Post -Body $jsonBody -ContentType 'application/json' -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Status    = 'Message sent to Microsoft Teams'
            Title     = $Title
        }
    }
    catch { throw }
}
