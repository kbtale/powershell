#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits compliance policy states for a managed device

.DESCRIPTION
    Retrieves the compliance state for all policies applied to a specifies managed device in Microsoft Graph.

.PARAMETER Identity
    Specifies the ID of the managed device.

.PARAMETER PolicyStateId
    Optional. Specifies the ID of a specific compliance policy state to retrieve. If omitted, all policy states for the device are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphManagedDeviceCompliancePolicyState.ps1 -Identity "device-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$PolicyStateId
)

Process {
    try {
        $params = @{
            'ManagedDeviceId' = $Identity
            'ErrorAction'     = 'Stop'
        }

        if ($PolicyStateId) {
            $params.Add('DeviceCompliancePolicyStateId', $PolicyStateId)
        }
        else {
            $params.Add('All', $true)
        }

        $states = Get-MgDeviceManagementManagedDeviceCompliancePolicyState @params
        
        $results = foreach ($s in $states) {
            [PSCustomObject]@{
                DisplayName  = $s.DisplayName
                Platform     = $s.PlatformType
                State        = $s.State
                SettingCount = $s.SettingCount
                Id           = $s.Id
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
