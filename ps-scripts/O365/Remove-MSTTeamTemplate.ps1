#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Delete a Team Template
.DESCRIPTION
    Deletes a specified Team Template from Microsoft Teams by ODataId or by name.
.PARAMETER ODataId
    Composite URI of the template
.PARAMETER Name
    Name of the template to delete
.EXAMPLE
    PS> ./Remove-MSTTeamTemplate.ps1 -ODataId "https://...template-id"
.EXAMPLE
    PS> ./Remove-MSTTeamTemplate.ps1 -Name "My Template"
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
            $null = Remove-CsTeamTemplate -OdataId $ODataId -ErrorAction Stop
            $templateId = $ODataId
        }
        else {
            $null = (Get-CsTeamTemplateList -ErrorAction Stop) | Where-Object Name -eq $Name | ForEach-Object { Remove-CsTeamTemplate -OdataId $_.OdataId -ErrorAction Stop }
            $templateId = $Name
        }

        [PSCustomObject]@{
            Timestamp  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            TemplateId = $templateId
            Status     = 'Team template successfully removed'
        }
    }
    catch { throw }
}
