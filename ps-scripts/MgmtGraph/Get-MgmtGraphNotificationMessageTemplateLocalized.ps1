#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits localized notification messages

.DESCRIPTION
    Retrieves the localized content (subject/body) for a specifies notification message template in Microsoft Graph.

.PARAMETER TemplateId
    Specifies the ID of the notification message template.

.PARAMETER MessageId
    Optional. Specifies the ID of a specific localized message to retrieve. If omitted, all localized messages for the template are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphNotificationMessageTemplateLocalized.ps1 -TemplateId "template-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TemplateId,

    [string]$MessageId
)

Process {
    try {
        $params = @{
            'NotificationMessageTemplateId' = $TemplateId
            'ErrorAction'                   = 'Stop'
        }

        if ($MessageId) {
            $params.Add('LocalizedNotificationMessageId', $MessageId)
        }
        else {
            $params.Add('All', $true)
        }

        $messages = Get-MgDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage @params
        
        $results = foreach ($m in $messages) {
            [PSCustomObject]@{
                TemplateId   = $TemplateId
                Locale       = $m.Locale
                Subject      = $m.Subject
                IsDefault    = $m.IsDefault
                LastModified = $m.LastModifiedDateTime
                Id           = $m.Id
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Locale)
    }
    catch {
        throw
    }
}
