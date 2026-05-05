#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits configuration setting state summaries

.DESCRIPTION
    Retrieves the aggregate deployment state summary for individual settings within Intune device configuration profiles from Microsoft Graph.

.PARAMETER ConfigurationId
    Specifies the ID of the device configuration profile.

.PARAMETER SettingId
    Optional. Specifies the ID of a specific setting state summary to retrieve. If omitted, all summaries for the profile are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceConfigurationDeviceSettingStateSummary.ps1 -ConfigurationId "config-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ConfigurationId,

    [string]$SettingId
)

Process {
    try {
        $params = @{
            'DeviceConfigurationId' = $ConfigurationId
            'ErrorAction'           = 'Stop'
        }

        if ($SettingId) {
            $params.Add('SettingStateDeviceSummaryId', $SettingId)
        }
        else {
            $params.Add('All', $true)
        }

        $summaries = Get-MgDeviceManagementDeviceConfigurationDeviceSettingStateSummary @params
        
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
