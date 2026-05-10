#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves all properties of a group
.DESCRIPTION
    Gets every property of a specified Azure AD group identified by object ID or display name.
.PARAMETER GroupObjectId
    Unique object ID of the group
.PARAMETER GroupName
    Display name of the group
.EXAMPLE
    PS> ./Get-GroupProperty.ps1 -GroupName "Sales Team"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "GroupName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "GroupObjectId")]
    [guid]$GroupObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "GroupName")]
    [string]$GroupName
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "GroupObjectId") {
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop | Select-Object *
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName } | Select-Object *
        }

        if ($null -eq $grp) { throw "Group not found" }

        $grp | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
