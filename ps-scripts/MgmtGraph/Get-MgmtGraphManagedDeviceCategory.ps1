#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits the category for a managed device

.DESCRIPTION
    Retrieves the device category currently assigned to a specifies managed device in Microsoft Graph.

.PARAMETER Identity
    Specifies the ID of the managed device.

.EXAMPLE
    PS> ./Get-MgmtGraphManagedDeviceCategory.ps1 -Identity "device-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $category = Get-MgDeviceManagementManagedDeviceCategory -ManagedDeviceId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            DeviceId    = $Identity
            DisplayName = $category.DisplayName
            Description = $category.Description
            Id          = $category.Id
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
