#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits Intune device compliance policies

.DESCRIPTION
    Retrieves properties for a specifies device compliance policy or lists all policies currently defined in the Intune tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the device compliance policy to retrieve. If omitted, all policies are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphDeviceCompliancePolicy.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Identity) {
            $params.Add('DeviceCompliancePolicyId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $policies = Get-MgDeviceManagementDeviceCompliancePolicy @params
        
        $results = foreach ($p in $policies) {
            [PSCustomObject]@{
                DisplayName  = $p.DisplayName
                Description  = $p.Description
                Platform     = $p.OdataType
                Id           = $p.Id
                Version      = $p.Version
                LastModified = $p.LastModifiedDateTime
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
