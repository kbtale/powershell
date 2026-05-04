#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Deletes a Microsoft Graph device

.DESCRIPTION
    Removes a specifies device from the Microsoft Graph tenant. This action is permanent.

.PARAMETER Identity
    Specifies the ID of the device to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphDevice.ps1 -Identity "device-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'DeviceId'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgDevice @params
        
        $result = [PSCustomObject]@{
            DeviceId  = $Identity
            Action    = "DeviceRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
