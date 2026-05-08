#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Get user properties from Azure AD
.DESCRIPTION
    Retrieves properties of an Azure AD user using the MSOnline module.
.PARAMETER UserObjectId
    Unique ID of the user
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOUserProperties.ps1 -UserName "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$UserName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $result = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ErrorAction Stop | Select-Object * }
        else { $result = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ErrorAction Stop | Select-Object * }

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No user found"; return }
        foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force }
    }
    catch { throw }
}
