#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits device status for an Intune configuration profile

.DESCRIPTION
    Retrieves the per-device deployment status for a specifies device configuration profile in Microsoft Graph.

.PARAMETER ConfigurationId
    Specifies the ID of the device configuration profile.

.PARAMETER StatusId
    Optional. Specifies the ID of a specific device status to retrieve. If omitted, all device statuses for the profile are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceConfigurationDeviceStatus.ps1 -ConfigurationId "config-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ConfigurationId,

    [string]$StatusId
)

Process {
    try {
        $params = @{
            'DeviceConfigurationId' = $ConfigurationId
            'ErrorAction'           = 'Stop'
        }

        if ($StatusId) {
            $params.Add('DeviceConfigurationDeviceStatusId', $StatusId)
        }
        else {
            $params.Add('All', $true)
        }

        $statuses = Get-MgDeviceManagementDeviceConfigurationDeviceStatuses @params
        
        $results = foreach ($s in $statuses) {
            [PSCustomObject]@{
                DeviceName          = $s.DeviceName
                UserPrincipalName   = $s.UserPrincipalName
                Status              = $s.Status
                LastReported        = $s.LastReportedDateTime
                Id                  = $s.Id
                Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DeviceName)
    }
    catch {
        throw
    }
}
