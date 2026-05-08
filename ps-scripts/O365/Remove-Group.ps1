#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Removes a group

.DESCRIPTION
    Removes a group from Azure Active Directory.

.PARAMETER GroupObjectId
    Unique ID of the group to remove

.PARAMETER GroupName
    Display name of the group to remove

.EXAMPLE
    PS> ./Remove-Group.ps1 -GroupName "Sales Team"

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
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName }
        }

        if ($null -ne $grp) {
            $null = Remove-AzureADGroup -ObjectId $grp.ObjectId -ErrorAction Stop
            [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Status    = "Success"
                GroupName = $grp.DisplayName
                ObjectId  = $grp.ObjectId
                Message   = "Group '$($grp.DisplayName)' removed"
            }
        }
        else {
            throw "Group not found"
        }
    }
    catch {
        throw
    }
}
