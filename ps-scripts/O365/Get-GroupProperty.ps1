#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves the properties of a group

.DESCRIPTION
    Retrieves all properties of a specified Azure Active Directory group.

.PARAMETER GroupObjectId
    Unique ID of the group to retrieve

.PARAMETER GroupName
    Display name of the group to retrieve

.EXAMPLE
    PS> ./Get-GroupProperty.ps1 -GroupName "Sales Team"

.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Group name")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Group object id")]
    [guid]$GroupObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "Group name")]
    [string]$GroupName
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "Group object id") {
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop | Select-Object *
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName } | Select-Object *
        }

        if ($null -ne $grp) {
            $grp | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
        else {
            throw "Group not found"
        }
    }
    catch {
        throw
    }
}
