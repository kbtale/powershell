#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Updates Intune device category properties

.DESCRIPTION
    Modifies the configuration details for a specifies device category, such as its display name or description.

.PARAMETER Identity
    Specifies the ID of the device category to update.

.PARAMETER DisplayName
    Optional. Specifies the new display name for the device category.

.PARAMETER Description
    Optional. Specifies the new description for the device category.

.EXAMPLE
    PS> ./Set-MgmtGraphDeviceCategory.ps1 -Identity "category-id" -DisplayName "Updated Sales"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$DisplayName,

    [string]$Description
)

Process {
    try {
        $params = @{
            'DeviceCategoryId' = $Identity
            'Confirm'          = $false
            'ErrorAction'      = 'Stop'
        }

        if ($DisplayName) { $params.Add('DisplayName', $DisplayName) }
        if ($Description) { $params.Add('Description', $Description) }

        if ($params.Count -gt 3) {
            Update-MgDeviceManagementDeviceCategory @params
            
            $result = [PSCustomObject]@{
                Id          = $Identity
                DisplayName = $DisplayName
                Action      = "DeviceCategoryUpdated"
                Status      = "Success"
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for device category."
        }
    }
    catch {
        throw
    }
}
