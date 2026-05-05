#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Deletes an Intune device category

.DESCRIPTION
    Removes a specifies device category from the Microsoft Graph tenant. This action is irreversible.

.PARAMETER Identity
    Specifies the ID of the device category to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphDeviceCategory.ps1 -Identity "category-id"

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
            'DeviceCategoryId' = $Identity
            'Confirm'          = $false
            'ErrorAction'      = 'Stop'
        }

        Remove-MgDeviceManagementDeviceCategory @params
        
        $result = [PSCustomObject]@{
            Id        = $Identity
            Action    = "DeviceCategoryRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
