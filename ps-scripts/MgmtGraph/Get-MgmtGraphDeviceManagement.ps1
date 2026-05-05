#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune device management service status

.DESCRIPTION
    Retrieves the top-level device management settings and service status from Microsoft Graph, including subscription state and tenant capabilities.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceManagement.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $mgmt = Get-MgDeviceManagement -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            SubscriptionState         = $mgmt.SubscriptionState
            IntuneAccountId           = $mgmt.IntuneAccountId
            Settings                  = $mgmt.Settings
            Id                        = $mgmt.Id
            Timestamp                 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
