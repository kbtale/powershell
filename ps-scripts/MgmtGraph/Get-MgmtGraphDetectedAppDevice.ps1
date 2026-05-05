#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits devices associated with a detected application

.DESCRIPTION
    Retrieves the list of managed devices where a specifies application has been detected.

.PARAMETER AppId
    Specifies the ID of the detected application.

.PARAMETER DeviceId
    Optional. Specifies the ID of a specific managed device to check for the application.

.EXAMPLE
    PS> ./Get-MgmtGraphDetectedAppDevice.ps1 -AppId "app-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$AppId,

    [string]$DeviceId
)

Process {
    try {
        $params = @{
            'DetectedAppId' = $AppId
            'ErrorAction'   = 'Stop'
        }

        if ($DeviceId) {
            $params.Add('ManagedDeviceId', $DeviceId)
        }
        else {
            $params.Add('All', $true)
        }

        $devices = Get-MgDeviceManagementDetectedAppManagedDevice @params
        
        $results = foreach ($d in $devices) {
            [PSCustomObject]@{
                AppId               = $AppId
                DeviceName          = $d.DeviceName
                DeviceId            = $d.Id
                OperatingSystem     = $d.OperatingSystem
                OSVersion           = $d.OSVersion
                UserPrincipalName   = $d.UserPrincipalName
                Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DeviceName)
    }
    catch {
        throw
    }
}
