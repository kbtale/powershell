#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Updates group properties
.DESCRIPTION
    Modifies the description and/or display name of a group. Only supplied parameters are applied.
.PARAMETER GroupObjectId
    Unique object ID of the group to update
.PARAMETER GroupName
    Display name of the group to update
.PARAMETER Description
    New description for the group
.PARAMETER DisplayName
    New display name for the group
.EXAMPLE
    PS> ./Set-GroupProperty.ps1 -GroupName "Sales Team" -Description "Updated description"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "GroupName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "GroupObjectId")]
    [guid]$GroupObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "GroupName")]
    [string]$GroupName,

    [Parameter(ParameterSetName = "GroupName")]
    [Parameter(ParameterSetName = "GroupObjectId")]
    [string]$Description,

    [Parameter(ParameterSetName = "GroupName")]
    [Parameter(ParameterSetName = "GroupObjectId")]
    [string]$DisplayName
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "GroupObjectId") {
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName }
        }

        if ($null -eq $grp) { throw "Group not found" }

        if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
            $null = Set-AzureADGroup -ObjectId $grp.ObjectId -Description $Description -ErrorAction Stop
        }
        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) {
            $null = Set-AzureADGroup -ObjectId $grp.ObjectId -DisplayName $DisplayName -ErrorAction Stop
        }

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            GroupName = $grp.DisplayName
            ObjectId  = $grp.ObjectId
            Message   = "Group '$($grp.DisplayName)' updated"
        }
    }
    catch { throw }
}
