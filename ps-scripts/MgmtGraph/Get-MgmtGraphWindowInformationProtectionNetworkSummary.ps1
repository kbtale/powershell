#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits WIP network learning summaries

.DESCRIPTION
    Retrieves the Windows Information Protection (WIP) network learning summary from Microsoft Graph, identifying network endpoints that are being accessed.

.PARAMETER Identity
    Optional. Specifies the ID of the WIP network learning summary to retrieve. If omitted, all summaries are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphWindowInformationProtectionNetworkSummary.ps1

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
            $params.Add('WindowsInformationProtectionNetworkLearningSummaryId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $summaries = Get-MgDeviceManagementWindowInformationProtectionNetworkLearningSummary @params
        
        $results = foreach ($s in $summaries) {
            [PSCustomObject]@{
                Url         = $s.Url
                DeviceCount = $s.DeviceCount
                Id          = $s.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Url)
    }
    catch {
        throw
    }
}
