#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune device configuration assignments

.DESCRIPTION
    Retrieves the assignments for a specifies device configuration profile, showing which groups or users are targeted.

.PARAMETER ConfigurationId
    Specifies the ID of the device configuration profile.

.PARAMETER AssignmentId
    Optional. Specifies the ID of a specific assignment to retrieve. If omitted, all assignments for the profile are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceConfigurationAssignment.ps1 -ConfigurationId "config-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ConfigurationId,

    [string]$AssignmentId
)

Process {
    try {
        $params = @{
            'DeviceConfigurationId' = $ConfigurationId
            'ErrorAction'           = 'Stop'
        }

        if ($AssignmentId) {
            $params.Add('DeviceConfigurationAssignmentId', $AssignmentId)
        }
        else {
            $params.Add('All', $true)
        }

        $assignments = Get-MgDeviceManagementDeviceConfigurationAssignment @params
        
        $results = foreach ($a in $assignments) {
            [PSCustomObject]@{
                ConfigurationId = $ConfigurationId
                AssignmentId    = $a.Id
                Target          = $a.Target.OdataType
                GroupId         = $a.Target.GroupId
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
