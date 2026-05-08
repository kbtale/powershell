#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Adds users to directory roles
.DESCRIPTION
    Assigns users to Azure AD directory roles. Supports identity resolution by display name or object ID.
.PARAMETER RoleIds
    Object IDs of the roles to assign users to
.PARAMETER UserIds
    Object IDs of the users to assign
.PARAMETER RoleNames
    Display names of the roles to assign users to
.PARAMETER UserNames
    Display names or UPNs of the users to assign
.EXAMPLE
    PS> ./Add-UserToRole.ps1 -RoleNames "Helpdesk Administrator" -UserNames "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Names")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Ids")]
    [guid[]]$RoleIds,

    [Parameter(Mandatory = $true, ParameterSetName = "Ids")]
    [guid[]]$UserIds,

    [Parameter(Mandatory = $true, ParameterSetName = "Names")]
    [string[]]$RoleNames,

    [Parameter(Mandatory = $true, ParameterSetName = "Names")]
    [string[]]$UserNames
)

Process {
    try {
        $results = [System.Collections.ArrayList]::new()

        if ($PSCmdlet.ParameterSetName -eq "Names") {
            $resolvedRoles = @()
            foreach ($name in $RoleNames) {
                try {
                    $tmp = Get-AzureADDirectoryRole -ErrorAction Stop | Where-Object -Property DisplayName -eq $name
                    if ($null -ne $tmp) { $resolvedRoles += $tmp.ObjectID }
                    else { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Role '$name' not found" }) }
                }
                catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Role '$name' not found" }) }
            }
            $RoleIds = $resolvedRoles

            if ($null -ne $UserNames) {
                $resolvedUsers = @()
                foreach ($name in $UserNames) {
                    try {
                        $tmp = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $name) -or ($_.UserPrincipalName -eq $name) }
                        if ($null -ne $tmp) { $resolvedUsers += $tmp.ObjectID }
                        else { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$name' not found" }) }
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$name' not found" }) }
                }
                $UserIds = $resolvedUsers
            }
        }

        foreach ($rid in $RoleIds) {
            try { $role = Get-AzureADDirectoryRole -ObjectId $rid -ErrorAction Stop | Select-Object ObjectID, DisplayName }
            catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Role ID '$rid' not found" }); continue }

            if ($null -ne $UserIds) {
                foreach ($uid in $UserIds) {
                    try { $usr = Get-AzureADUser -ObjectId $uid -ErrorAction Stop | Select-Object ObjectID, DisplayName }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User ID '$uid' not found" }); continue }

                    try {
                        $null = Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectID -RefObjectId $usr.ObjectID -ErrorAction Stop
                        $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User '$($usr.DisplayName)' added to role '$($role.DisplayName)'" })
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$($usr.DisplayName)': $($_.Exception.Message)" }) }
                }
            }
        }

        Write-Output $results
    }
    catch { throw }
}
