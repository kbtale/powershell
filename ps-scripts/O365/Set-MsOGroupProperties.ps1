#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Update Azure AD group properties
.DESCRIPTION
    Updates properties of an Azure Active Directory group using the MSOnline module.
.PARAMETER GroupObjectId
    Unique ID of the group to update
.PARAMETER GroupName
    Display name of the group to update
.PARAMETER Description
    New description for the group
.PARAMETER DisplayName
    New display name for the group
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Set-MsOGroupProperties.ps1 -GroupName "Sales Team" -DisplayName "Sales Department"
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
    [string]$Description,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [string]$DisplayName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $grp = Get-MsolGroup -SearchString $GroupName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        [hashtable]$setArgs = @{'ErrorAction' = 'Stop'; 'ObjectId' = $grp.ObjectId; 'TenantId' = $TenantId}
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) { $setArgs.Add('Description', $Description) }
        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) { $setArgs.Add('DisplayName', $DisplayName) }

        Set-MsolGroup @setArgs
        $result = Get-MsolGroup -ObjectId $grp.ObjectId -TenantId $TenantId -ErrorAction Stop | Select-Object *
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
