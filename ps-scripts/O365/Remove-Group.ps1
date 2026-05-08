#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Removes a group from the tenant
.DESCRIPTION
    Removes an Azure Active Directory group identified by object ID or display name.
.PARAMETER GroupObjectId
    Unique object ID of the group to remove
.PARAMETER GroupName
    Display name of the group to remove
.EXAMPLE
    PS> ./Remove-Group.ps1 -GroupName "Sales Team"
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
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName }
        }

        if ($null -eq $grp) { throw "Group not found" }

        $null = Remove-AzureADGroup -ObjectId $grp.ObjectId -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            GroupName = $grp.DisplayName
            ObjectId  = $grp.ObjectId
            Message   = "Group '$($grp.DisplayName)' removed"
        }
    }
    catch { throw }
}
