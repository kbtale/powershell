#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Query-format list of users from a group
.DESCRIPTION
    Returns users from a group as Value/DisplayValue pairs for use in dropdown selectors.
.PARAMETER GroupObjectId
    Unique object ID of the group
.EXAMPLE
    PS> ./Get-GroupUser.ps1 -GroupObjectId "00000000-0000-0000-0000-000000000000"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [guid]$GroupObjectId
)

Process {
    try {
        $members = Get-AzureADGroupMember -ObjectId $GroupObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'User' } | Sort-Object -Property DisplayName

        foreach ($usr in $members) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $usr.ObjectId
                DisplayValue = $usr.DisplayName
            }
        }
    }
    catch { throw }
}
