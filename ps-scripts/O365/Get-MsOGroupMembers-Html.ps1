#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: HTML report of group members
.DESCRIPTION
    Generates an HTML report with members of an Azure AD group.
.PARAMETER GroupObjectId
    Unique ID of the group
.PARAMETER GroupName
    Display name of the group
.PARAMETER Nested
    Show nested members
.PARAMETER MemberObjectTypes
    Filter by member object types
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOGroupMembers-Html.ps1 -GroupName "Sales Team" | Out-File report.html
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
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $grp = Get-MsolGroup -SearchString $GroupName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        $getArgs = @{'ErrorAction' = 'Stop'; 'GroupObjectId' = $grp.ObjectId; 'TenantId' = $TenantId}
        if ($MemberObjectTypes) { $getArgs.Add('MemberObjectTypes', $MemberObjectTypes) }
        if ($Nested) { $getArgs.Add('All', $true) }

        $result = Get-MsolGroupMember @getArgs | Select-Object DisplayName, EmailAddress, ObjectType, UserPrincipalName
        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No group members found"; return }
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
