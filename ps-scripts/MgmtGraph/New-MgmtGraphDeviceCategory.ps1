#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Provisions a new Intune device category

.DESCRIPTION
    Creates a new device category in the Microsoft Graph tenant to help organize managed devices.

.PARAMETER DisplayName
    Specifies the display name for the new device category.

.PARAMETER Description
    Optional. Specifies a description for the new device category.

.EXAMPLE
    PS> ./New-MgmtGraphDeviceCategory.ps1 -DisplayName "Sales Devices" -Description "Devices assigned to the sales department"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DisplayName,

    [string]$Description
)

Process {
    try {
        $params = @{
            'DisplayName' = $DisplayName
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($Description) { $params.Add('Description', $Description) }

        $category = New-MgDeviceManagementDeviceCategory @params
        
        $result = [PSCustomObject]@{
            DisplayName = $DisplayName
            Id          = $category.Id
            Status      = "DeviceCategoryCreated"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
