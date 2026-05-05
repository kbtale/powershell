#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Deletes an Intune device compliance policy

.DESCRIPTION
    Removes a specifies device compliance policy from the Microsoft Graph tenant. This action is irreversible.

.PARAMETER Identity
    Specifies the ID of the device compliance policy to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphDeviceCompliancePolicy.ps1 -Identity "policy-id"

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
            'DeviceCompliancePolicyId' = $Identity
            'Confirm'                  = $false
            'ErrorAction'              = 'Stop'
        }

        Remove-MgDeviceManagementDeviceCompliancePolicy @params
        
        $result = [PSCustomObject]@{
            Id        = $Identity
            Action    = "DeviceCompliancePolicyRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
