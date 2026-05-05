#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune managed device overview

.DESCRIPTION
    Retrieves a high-level summary of managed device counts, categorized by enrollment status and platform, from Microsoft Graph.

.EXAMPLE
    PS> ./Get-MgmtGraphManagedDeviceOverview.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $overview = Get-MgDeviceManagementManagedDeviceOverview -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            DeviceCount             = $overview.DeviceCount
            DualEnrolledDeviceCount = $overview.DualEnrolledDeviceCount
            EnrolledDeviceCount     = $overview.EnrolledDeviceCount
            MdmEnrolledDeviceCount  = $overview.MdmEnrolledDeviceCount
            Timestamp               = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
