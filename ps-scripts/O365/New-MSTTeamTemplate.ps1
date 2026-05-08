#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Create a new team template
.DESCRIPTION
    Creates a new team template for use in Microsoft Teams.
.PARAMETER DisplayName
    Name of the template
.PARAMETER Locale
    The locale of the template
.PARAMETER ShortDescription
    Template short description
.PARAMETER Description
    The template description
.PARAMETER Categories
    List of categories
.PARAMETER DiscoverySettingShowInTeamsSearchAndSuggestion
    If teams created from this template are visible in search and suggestions
.PARAMETER Icon
    File path to icon image (.png, .gif, .jpg, or .jpeg)
.EXAMPLE
    PS> ./New-MSTTeamTemplate.ps1 -DisplayName "My Template" -Locale "en-US" -ShortDescription "Custom template"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [string]$Locale,
    [string]$ShortDescription,
    [string]$Description,
    [string]$Categories,
    [bool]$DiscoverySettingShowInTeamsSearchAndSuggestion,
    [string]$Icon
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'DisplayName' = $DisplayName}

        if (-not [System.String]::IsNullOrWhiteSpace($Locale)) { $cmdArgs.Add('Locale', $Locale) }
        if (-not [System.String]::IsNullOrWhiteSpace($ShortDescription)) { $cmdArgs.Add('ShortDescription', $ShortDescription) }
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) { $cmdArgs.Add('Description', $Description) }
        if (-not [System.String]::IsNullOrWhiteSpace($Categories)) { $cmdArgs.Add('Categories', $Categories) }
        if ($PSBoundParameters.ContainsKey('DiscoverySettingShowInTeamsSearchAndSuggestion')) { $cmdArgs.Add('DiscoverySettingShowInTeamsSearchAndSuggestion', $DiscoverySettingShowInTeamsSearchAndSuggestion) }
        if (-not [System.String]::IsNullOrWhiteSpace($Icon)) { $cmdArgs.Add('Icon', $Icon) }

        $result = New-CsTeamTemplate @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Team template created"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
