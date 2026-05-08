#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group open extensions

.DESCRIPTION
    Retrieves the custom open data extensions defined on a specified Microsoft Graph group.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ExtensionId
    Optional. The unique identifier of a specific group extension to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupExtension.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupExtension.ps1 -GroupId "group-id-123" -ExtensionId "ext-id-456"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [string]$ExtensionId
)

Process {
    try {
        $params = @{
            'GroupId'     = $GroupId
            'ErrorAction' = 'Stop'
        }

        if ($ExtensionId) {
            $params.Add('ExtensionId', $ExtensionId)
        }
        else {
            $params.Add('All', $true)
        }

        $extensions = Get-MgGroupExtension @params
        
        $results = foreach ($e in $extensions) {
            [PSCustomObject]@{
                GroupId     = $GroupId
                ExtensionId = $e.Id
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
