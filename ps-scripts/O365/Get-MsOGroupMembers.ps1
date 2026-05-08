#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Get group members from Azure AD
.DESCRIPTION
    Retrieves members from an Azure Active Directory group using the MSOnline module.
.PARAMETER GroupObjectId
    Unique ID of the group
.PARAMETER GroupName
    Display name of the group
.PARAMETER Nested
    Show group members nested recursively
.PARAMETER MemberObjectTypes
    Filter by member object types (User, Group, Contact, ServicePrincipal)
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOGroupMembers.ps1 -GroupName "Sales Team"
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
    [switch]$Nested,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [ValidateSet('User','Group','Contact','ServicePrincipal')]
    [string[]]$MemberObjectTypes,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $grp = Get-MsolGroup -SearchString $GroupName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        $getArgs = @{'ErrorAction' = 'Stop'; 'GroupObjectId' = $grp.ObjectId; 'TenantId' = $TenantId}
        if ($MemberObjectTypes) { $getArgs.Add('MemberObjectTypes', $MemberObjectTypes) }
        if ($Nested) { $getArgs.Add('All', $true) }

        $result = Get-MsolGroupMember @getArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No group members found"; return }
        foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force }
    }
    catch { throw }
}
