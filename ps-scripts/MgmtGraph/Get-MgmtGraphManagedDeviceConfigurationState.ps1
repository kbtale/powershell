#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits configuration profile states for a managed device

.DESCRIPTION
    Retrieves the deployment state for all configuration profiles applied to a specifies managed device in Microsoft Graph.

.PARAMETER Identity
    Specifies the ID of the managed device.

.PARAMETER ConfigurationId
    Optional. Specifies the ID of a specific configuration profile to retrieve. If omitted, all configuration states for the device are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphManagedDeviceConfigurationState.ps1 -Identity "device-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$ConfigurationId
)

Process {
    try {
        $params = @{
            'ManagedDeviceId' = $Identity
            'ErrorAction'     = 'Stop'
        }

        if ($ConfigurationId) {
            $params.Add('DeviceConfigurationId', $ConfigurationId)
        }
        else {
            $params.Add('All', $true)
        }

        $states = Get-MgDeviceManagementManagedDeviceConfigurationState @params
        
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
