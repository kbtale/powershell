#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: HTML report of user properties
.DESCRIPTION
    Generates an HTML report with properties of an Azure AD user.
.PARAMETER UserObjectId
    Unique ID of the user
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user
.PARAMETER Properties
    List of properties to expand. Use * for all
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOUserProperties-Html.ps1 -UserName "user@domain.com" | Out-File report.html
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
    [ValidateSet('*','DisplayName','UserPrincipalName','FirstName','LastName','Department','Title','UsageLocation','Country','City','State','PostalCode','PhoneNumber','MobilePhone','ObjectId')]
    [string[]]$Properties = @('DisplayName','UserPrincipalName','Department','Title','ObjectId'),
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $result = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ErrorAction Stop | Select-Object $Properties }
        else { $result = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ErrorAction Stop | Select-Object $Properties }

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No user found"; return }
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
