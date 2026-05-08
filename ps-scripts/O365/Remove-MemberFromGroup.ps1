#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Removes users and groups from target groups
.DESCRIPTION
    Removes users and/or groups from one or more target groups. Supports identity resolution by name or by object ID.
.PARAMETER TargetGroupNames
    Display names of the target groups to remove members from
.PARAMETER UserNames
    Display names or user principal names of users to remove
.PARAMETER GroupNames
    Display names of groups to remove
.PARAMETER GroupObjectIds
    Object IDs of the target groups to remove members from
.PARAMETER GroupIds
    Object IDs of the groups to remove
.PARAMETER UserIds
    Object IDs of the users to remove
.EXAMPLE
    PS> ./Remove-MemberFromGroup.ps1 -TargetGroupNames "Sales Team" -UserNames "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Names")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Names")]
    [string[]]$TargetGroupNames,

    [Parameter(ParameterSetName = "Names")]
    [string[]]$UserNames,

    [Parameter(ParameterSetName = "Names")]
    [string[]]$GroupNames,

    [Parameter(Mandatory = $true, ParameterSetName = "IDs")]
    [guid[]]$GroupObjectIds,

    [Parameter(ParameterSetName = "IDs")]
    [guid[]]$GroupIds,

    [Parameter(ParameterSetName = "IDs")]
    [guid[]]$UserIds
)

Process {
    try {
        $results = [System.Collections.ArrayList]::new()

        if ($PSCmdlet.ParameterSetName -eq "Names") {
            $resolvedObjectIds = @()
            foreach ($name in $TargetGroupNames) {
                try {
                    $tmp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object -Property DisplayName -eq $name
                    if ($null -ne $tmp) { $resolvedObjectIds += $tmp.ObjectID }
                    else { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Target group '$name' not found" }) }
                }
                catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Target group '$name' not found" }) }
            }
            $GroupObjectIds = $resolvedObjectIds

            if ($null -ne $UserNames) {
                $resolvedUserIds = @()
                foreach ($name in $UserNames) {
                    try {
                        $tmp = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $name) -or ($_.UserPrincipalName -eq $name) }
                        if ($null -ne $tmp) { $resolvedUserIds += $tmp.ObjectID }
                        else { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$name' not found" }) }
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$name' not found" }) }
                }
                $UserIds = $resolvedUserIds
            }

            if ($null -ne $GroupNames) {
                $resolvedGroupIds = @()
                foreach ($name in $GroupNames) {
                    try {
                        $tmp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object -Property DisplayName -eq $name
                        if ($null -ne $tmp) { $resolvedGroupIds += $tmp.ObjectID }
                        else { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$name' not found" }) }
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$name' not found" }) }
                }
                $GroupIds = $resolvedGroupIds
            }
        }

        foreach ($gid in $GroupObjectIds) {
            try { $grp = Get-AzureADGroup -ObjectId $gid -ErrorAction Stop }
            catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Target group '$gid' not found: $($_.Exception.Message)" }); continue }

            if ($null -ne $GroupIds) {
                foreach ($mid in $GroupIds) {
                    try { $memberGrp = Get-AzureADGroup -ObjectId $mid -ErrorAction Stop }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group ID '$mid' not found: $($_.Exception.Message)" }); continue }

                    if ($null -ne $memberGrp) {
                        try {
                            $null = Remove-AzureADGroupMember -ObjectId $gid -MemberId $mid -ErrorAction Stop
                            $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Group '$($memberGrp.DisplayName)' removed from '$($grp.DisplayName)'" })
                        }
                        catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group ID '$mid': $($_.Exception.Message)" }) }
                    }
                }
            }

            if ($null -ne $UserIds) {
                foreach ($uid in $UserIds) {
                    try { $usr = Get-AzureADUser -ObjectId $uid -ErrorAction Stop }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User ID '$uid' not found: $($_.Exception.Message)" }); continue }

                    if ($null -ne $usr) {
                        try {
                            $null = Remove-AzureADGroupMember -ObjectId $gid -MemberId $uid -ErrorAction Stop
                            $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User '$($usr.DisplayName)' removed from '$($grp.DisplayName)'" })
                        }
                        catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User ID '$uid': $($_.Exception.Message)" }) }
                    }
                }
            }
        }

        Write-Output $results
    }
    catch { throw }
}
