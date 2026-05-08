#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Query-format list of team templates
.DESCRIPTION
    Returns team templates as Value/DisplayValue pairs for use in dropdown selectors. Supports optional locale filtering.
.PARAMETER PublicTemplateLocale
    The language and country code of templates localization
.EXAMPLE
    PS> ./QRY_Get-MSTTeamTemplateList.ps1
.EXAMPLE
    PS> ./QRY_Get-MSTTeamTemplateList.ps1 -PublicTemplateLocale "en-US"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$PublicTemplateLocale
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
        if ($PSBoundParameters.ContainsKey('PublicTemplateLocale')) {
            $cmdArgs.Add('PublicTemplateLocale', $PublicTemplateLocale)
        }

        $templates = Get-CsTeamTemplateList @cmdArgs | Sort-Object Name

        if ($null -eq $templates -or $templates.Count -eq 0) {
            Write-Output "No team templates found"
            return
        }
        foreach ($itm in $templates) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                Value        = $itm.OdataId
                DisplayValue = $itm.Name
            }
        }
    }
    catch { throw }
}
