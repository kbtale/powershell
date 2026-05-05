#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune-managed devices

.DESCRIPTION
    Retrieves properties for a specifies managed device or lists all devices currently managed by Intune in Microsoft Graph.

.PARAMETER Identity
    Optional. Specifies the ID of the managed device to retrieve. If omitted, all managed devices are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphManagedDevice.ps1

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
            $params.Add('ManagedDeviceId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $devices = Get-MgDeviceManagementManagedDevice @params
        
        $results = foreach ($d in $devices) {
            [PSCustomObject]@{
                DeviceName          = $d.DeviceName
                Id                  = $d.Id
                Manufacturer        = $d.Manufacturer
                Model               = $d.Model
                OperatingSystem     = $d.OperatingSystem
                OSVersion           = $d.OSVersion
                ComplianceState     = $d.ComplianceState
                ManagementAgent     = $d.ManagementAgent
                UserPrincipalName   = $d.UserPrincipalName
                LastSyncDateTime    = $d.LastSyncDateTime
                Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DeviceName)
    }
    catch {
        throw
    }
}
