#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get team template details
.DESCRIPTION
    Retrieves details of a team template available to the tenant by ODataId or by name.
.PARAMETER ODataId
    A composite URI of a template
.PARAMETER Name
    Name of the template to look up
.EXAMPLE
    PS> ./Get-MSTTeamTemplate.ps1 -ODataId "https://...template-id"
.EXAMPLE
    PS> ./Get-MSTTeamTemplate.ps1 -Name "Manage a Project"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
    [string]$ODataId,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$Name
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            $result = Get-CsTeamTemplate -OdataId $ODataId -ErrorAction Stop | Select-Object *
        }
        else {
            $result = (Get-CsTeamTemplateList -ErrorAction Stop) | Where-Object Name -eq $Name | ForEach-Object { Get-CsTeamTemplate -OdataId $_.OdataId -ErrorAction Stop } | Select-Object *
        }

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No team template found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
