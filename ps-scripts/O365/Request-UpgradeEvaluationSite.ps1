#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Requests an upgrade evaluation site copy
.DESCRIPTION
    Creates a copy of an existing site collection to validate upgrade effects without affecting the original.
.PARAMETER Identity
    URL of the site collection for which to request an evaluation copy
.PARAMETER NoEmail
    Do not send email notification upon completion
.PARAMETER NoUpgrade
    Do not perform upgrade as part of the evaluation site creation
.EXAMPLE
    PS> ./Request-UpgradeEvaluationSite.ps1 -Identity "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [switch]$NoEmail,
    [switch]$NoUpgrade
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity; Confirm = $false; NoEmail = $NoEmail; NoUpgrade = $NoUpgrade }
        $result = Request-SPOUpgradeEvaluationSite @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}