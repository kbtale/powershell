#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Get group properties from Azure AD
.DESCRIPTION
    Retrieves properties of an Azure Active Directory group using the MSOnline module.
.PARAMETER GroupObjectId
    Unique ID of the group
.PARAMETER GroupName
    Display name of the group
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOGroupProperties.ps1 -GroupName "Sales Team"
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
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $result = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId -ErrorAction Stop | Select-Object * }
        else { $result = Get-MsolGroup -SearchString $GroupName -TenantId $TenantId -ErrorAction Stop | Select-Object * }

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No group found"; return }
        foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force }
    }
    catch { throw }
}
