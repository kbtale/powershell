#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    MgmtGraph: Audits WIP app learning summaries

.DESCRIPTION
    Retrieves the Windows Information Protection (WIP) application learning summary from Microsoft Graph, identifying apps that are accessing corporate data.

.PARAMETER Identity
    Optional. Specifies the ID of the WIP app learning summary to retrieve. If omitted, all summaries are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphWindowInformationProtectionAppSummary.ps1

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
            $params.Add('WindowsInformationProtectionAppLearningSummaryId', $Identity)
        }
        else {
            $params.Add('All', $true)
        }

        $summaries = Get-MgDeviceManagementWindowInformationProtectionAppLearningSummary @params
        
        $results = foreach ($s in $summaries) {
            [PSCustomObject]@{
                ApplicationName = $s.ApplicationName
                ApplicationType = $s.ApplicationType
                DeviceCount     = $s.DeviceCount
                Id              = $s.Id
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object ApplicationName)
    }
    catch {
        throw
    }
}
