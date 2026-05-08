#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Remove a group from Azure AD
.DESCRIPTION
    Removes a group from Azure Active Directory using the MSOnline module.
.PARAMETER GroupObjectId
    Unique ID of the group to remove
.PARAMETER GroupName
    Display name of the group to remove
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Remove-MsOGroup.ps1 -GroupName "Old Group"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
    [guid]$GroupObjectId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$GroupName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $grp = Get-MsolGroup -SearchString $GroupName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        $null = Remove-MsolGroup -ObjectId $grp.ObjectId -TenantId $TenantId -ErrorAction Stop

        [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; GroupName = $grp.DisplayName; Status = "Group '$($grp.DisplayName)' removed" }
    }
    catch { throw }
}
