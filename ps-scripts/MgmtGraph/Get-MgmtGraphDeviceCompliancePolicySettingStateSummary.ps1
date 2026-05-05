#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits compliance policy setting state summaries

.DESCRIPTION
    Retrieves the aggregate deployment state summary for individual settings within Intune compliance policies from Microsoft Graph.

.PARAMETER Identity
    Optional. Specifies the ID of the setting state summary to retrieve. If omitted, all summaries are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicySettingStateSummary.ps1

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
            $params.Add('DeviceCompliancePolicySettingStateSummaryId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $summaries = Get-MgDeviceManagementDeviceCompliancePolicySettingStateSummary @params
        
        $results = foreach ($s in $summaries) {
            [PSCustomObject]@{
                SettingName           = $s.SettingName
                CompliantDeviceCount  = $s.CompliantDeviceCount
                NonCompliantDeviceCount = $s.NonCompliantDeviceCount
                ErrorDeviceCount      = $s.ErrorDeviceCount
                ConflictDeviceCount   = $s.ConflictDeviceCount
                Id                    = $s.Id
                Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object SettingName)
    }
    catch {
        throw
    }
}
