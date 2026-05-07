#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group OneNote notebook from a web URL

.DESCRIPTION
    Retrieves the properties of a group OneNote notebook specified by its web URL from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER WebUrl
    The web URL of the OneNote notebook to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupOnenoteNotebookFromWebUrl.ps1 -GroupId "group-id-123" -WebUrl "https://onedrive.live.com/..."

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$WebUrl
)

Process {
    try {
        $notebook = Get-MgGroupOnenoteNotebookFromWebUrl -GroupId $GroupId -WebUrl $WebUrl -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupId       = $GroupId
            NotebookId    = $notebook.Id
            DisplayName   = $notebook.DisplayName
            WebUrl        = $notebook.Self ?? $WebUrl
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
