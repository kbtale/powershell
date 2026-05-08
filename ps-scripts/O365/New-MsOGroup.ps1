#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Create a new Azure AD group
.DESCRIPTION
    Creates a new group in Azure Active Directory using the MSOnline module.
.PARAMETER GroupName
    Display name of the group
.PARAMETER Description
    Description of the group
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./New-MsOGroup.ps1 -GroupName "New Team" -Description "Project group"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [string]$Description,
    [guid]$TenantId
)

Process {
    try {
        $result = New-MsolGroup -DisplayName $GroupName -Description $Description -TenantId $TenantId -ErrorAction Stop | Select-Object *

        if ($null -eq $result) { Write-Output "Failed to create group"; return }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
