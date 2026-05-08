#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get all team templates available to the tenant
.DESCRIPTION
    Retrieves information of all team templates available to the tenant. Supports optional locale filtering.
.PARAMETER PublicTemplateLocale
    The language and country code of templates localization
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-MSTTeamTemplateList.ps1
.EXAMPLE
    PS> ./Get-MSTTeamTemplateList.ps1 -PublicTemplateLocale "en-US"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$PublicTemplateLocale,
    [ValidateSet('*','AppCount','Category','ChannelCount','Description','IconUri','Id','Locale','ModifiedBy','ModifiedOn','Name','OdataId','PublishedBy','Scope','ShortDescription','Visibility')]
    [string[]]$Properties = @('Name','OdataId','ShortDescription','AppCount','ChannelCount','ModifiedBy','ModifiedOn','Scope','Visibility')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
        if ($PSBoundParameters.ContainsKey('PublicTemplateLocale')) {
            $cmdArgs.Add('PublicTemplateLocale', $PublicTemplateLocale)
        }

        $result = Get-CsTeamTemplateList @cmdArgs | Select-Object $Properties

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No team templates found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
