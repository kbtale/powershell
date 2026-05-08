#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Update a custom team template
.DESCRIPTION
    Updates a custom team template with new settings. Supports updating template properties by ODataId or by name.
.PARAMETER ODataId
    Composite URI of the template
.PARAMETER Name
    Name of the template to update
.PARAMETER ShortDescription
    Template short description
.PARAMETER Description
    The template description
.PARAMETER Categories
    List of categories
.PARAMETER DiscoverySettingShowInTeamsSearchAndSuggestion
    If teams are visible in search and suggestions
.PARAMETER Icon
    File path to icon image
.EXAMPLE
    PS> ./Update-MSTTeamTemplate.ps1 -ODataId "https://...template-id" -ShortDescription "Updated description"
.EXAMPLE
    PS> ./Update-MSTTeamTemplate.ps1 -Name "My Template" -Description "Updated"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
    [string]$ODataId,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$Name,
    [string]$ShortDescription,
    [string]$Description,
    [string]$Categories,
    [bool]$DiscoverySettingShowInTeamsSearchAndSuggestion,
    [string]$Icon
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $template = (Get-CsTeamTemplateList -ErrorAction Stop) | Where-Object Name -eq $Name | Select-Object -First 1
            if ($null -ne $template) { $cmdArgs.Add('ODataId', $template.OdataId) }
        }
        else {
            $cmdArgs.Add('ODataId', $ODataId)
        }

        if (-not [System.String]::IsNullOrWhiteSpace($ShortDescription)) { $cmdArgs.Add('ShortDescription', $ShortDescription) }
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) { $cmdArgs.Add('Description', $Description) }
        if (-not [System.String]::IsNullOrWhiteSpace($Categories)) { $cmdArgs.Add('Categories', $Categories) }
        if ($PSBoundParameters.ContainsKey('DiscoverySettingShowInTeamsSearchAndSuggestion')) { $cmdArgs.Add('DiscoverySettingShowInTeamsSearchAndSuggestion', $DiscoverySettingShowInTeamsSearchAndSuggestion) }
        if (-not [System.String]::IsNullOrWhiteSpace($Icon)) { $cmdArgs.Add('Icon', $Icon) }

        $result = Update-CsTeamTemplate @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Team template updated"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
