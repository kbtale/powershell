#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune notification message templates

.DESCRIPTION
    Retrieves properties for a specifies notification message template or lists all templates available in the Intune tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the notification message template to retrieve. If omitted, all templates are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphNotificationMessageTemplate.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Identity) {
            $params.Add('NotificationMessageTemplateId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $templates = Get-MgDeviceManagementNotificationMessageTemplate @params
        
        $results = foreach ($t in $templates) {
            [PSCustomObject]@{
                DisplayName  = $t.DisplayName
                LastModified = $t.LastModifiedDateTime
                Id           = $t.Id
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
