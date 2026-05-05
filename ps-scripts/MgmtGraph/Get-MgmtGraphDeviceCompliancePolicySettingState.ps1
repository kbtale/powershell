#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune compliance setting states

.DESCRIPTION
    Retrieves the detailed deployment states for a specific setting within an Intune compliance policy from Microsoft Graph.

.PARAMETER SettingId
    Specifies the ID of the compliance policy setting state summary.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicySettingState.ps1 -SettingId "setting-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SettingId
)

Process {
    try {
        $states = Get-MgDeviceManagementDeviceCompliancePolicySettingStateSummaryDeviceComplianceSettingState -DeviceCompliancePolicySettingStateSummaryId $SettingId -ErrorAction Stop
        
        $results = foreach ($s in $states) {
            [PSCustomObject]@{
                SettingId    = $SettingId
                State        = $s.State
                InstanceId   = $s.Id
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
