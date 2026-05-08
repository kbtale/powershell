#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Checks and repairs a site collection
.DESCRIPTION
    Runs health checks and repairs on a SharePoint Online site collection and its contents.
.PARAMETER Identity
    URL of the site collection to repair
.PARAMETER RuleId
    Specific health check rule to run
.PARAMETER RunAlways
    Display what would happen instead of executing
.EXAMPLE
    PS> ./Repair-Site.ps1 -Identity "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [string]$RuleId,
    [switch]$RunAlways
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity; RunAlways = $RunAlways; Confirm = $false }
        if (-not [System.String]::IsNullOrWhiteSpace($RuleId)) { $cmdArgs.Add('RuleId', $RuleId) }
        $result = Repair-SPOSite @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}