#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune troubleshooting events

.DESCRIPTION
    Retrieves properties for a specifies troubleshooting event or lists all events currently logged in the Intune tenant for diagnostic purposes.

.PARAMETER Identity
    Optional. Specifies the ID of the troubleshooting event to retrieve. If omitted, all events are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphTroubleshootingEvent.ps1

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
            $params.Add('DeviceManagementTroubleshootingEventId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $events = Get-MgDeviceManagementTroubleshootingEvent @params
        
        $results = foreach ($e in $events) {
            [PSCustomObject]@{
                EventDateTime = $e.EventDateTime
                CorrelationId = $e.CorrelationId
                TroubleshootingType = $e.OdataType
                Id            = $e.Id
                Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object EventDateTime -Descending)
    }
    catch {
        throw
    }
}
