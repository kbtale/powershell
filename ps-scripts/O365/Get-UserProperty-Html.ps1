#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: HTML report of user properties
.DESCRIPTION
    Generates an HTML report of properties for a specified user or all users.
.PARAMETER UserObjectId
    Unique object ID of the user
.PARAMETER UserName
    Display name or UPN of the user
.PARAMETER Properties
    List of properties to include. Use * for all.
.EXAMPLE
    PS> ./Get-UserProperty-Html.ps1 -UserName "john.doe@contoso.com" | Out-File user.html
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "UserName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [guid]$UserObjectId,

    [Parameter(ParameterSetName = "UserName")]
    [string]$UserName,

    [ValidateSet('*', 'DisplayName', 'GivenName', 'Surname', 'Mail', 'ObjectId', 'AccountEnabled', 'Department', 'City', 'StreetAddress', 'TelephoneNumber', 'Country', 'CompanyName')]
    [string[]]$Properties = @('DisplayName', 'Surname', 'GivenName', 'Mail', 'AccountEnabled')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }

        if ($PSCmdlet.ParameterSetName -eq "UserObjectId") {
            $users = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $users = Get-AzureADUser -All $true -ErrorAction Stop | Select-Object $Properties
            if (-not [System.String]::IsNullOrWhiteSpace($UserName)) {
                $users = $users | Where-Object { ($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName) }
            }
        }

        if ($null -ne $users) { Write-Output ($users | ConvertTo-Html -Fragment) }
    }
    catch { throw }
}
