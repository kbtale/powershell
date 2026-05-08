#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group configuration settings

.DESCRIPTION
    Retrieves the properties of a specific group setting object or lists all settings defined under Microsoft Graph.

.PARAMETER GroupId
    Optional. The unique identifier of the Microsoft Graph group to retrieve specific settings for.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupSetting.ps1

.EXAMPLE
    PS> ./Get-MgmtGraphGroupSetting.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [string]$GroupId
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }
        if ($GroupId) {
            $params.Add('GroupId', $GroupId)
        }
        else {
            $params.Add('All', $true)
        }

        $settings = Get-MgGroupSetting @params
        
        $results = foreach ($s in $settings) {
            [PSCustomObject]@{
                Id          = $s.Id
                TemplateId  = $s.TemplateId
                DisplayName = $s.DisplayName
                Values      = ($s.Values | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "; "
                GroupId     = $GroupId
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
