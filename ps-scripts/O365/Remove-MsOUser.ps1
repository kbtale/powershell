#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Remove a user from Azure AD
.DESCRIPTION
    Removes a user from Azure Active Directory or permanently from the recycle bin.
.PARAMETER UserObjectId
    Unique ID of the user to remove
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user
.PARAMETER RemoveFromRecycleBin
    Permanently remove from the recycle bin
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Remove-MsOUser.ps1 -UserName "user@domain.com"
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
    [switch]$RemoveFromRecycleBin,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Id')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $user = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ErrorAction Stop }
        else { $user = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }

        $null = Remove-MsolUser -ObjectId $user.ObjectId -TenantId $TenantId -RemoveFromRecycleBin:$RemoveFromRecycleBin -Force -ErrorAction Stop

        [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; UserName = $user.UserPrincipalName; Status = "User '$($user.UserPrincipalName)' removed" }
    }
    catch { throw }
}
