#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Adds members (users or groups) to target groups

.DESCRIPTION
    Adds members (users or groups) to target groups by name or by object ID.

.PARAMETER TargetGroupNames
    Display names of the groups to which to add members

.PARAMETER UserNames
    Display names or user principal names of the users to add to the target groups

.PARAMETER GroupNames
    Display names of the groups to add to the target groups

.PARAMETER GroupObjectIds
    Unique IDs of the target groups to which to add members

.PARAMETER GroupIds
    Unique object IDs of the groups to add to the target groups

.PARAMETER UserIds
    Unique object IDs of the users to add to the target groups

.EXAMPLE
    PS> ./Add-MemberToGroup.ps1 -TargetGroupNames "Sales Team" -UserNames "john.doe@contoso.com"

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
        $results = @()
        $hasError = $false

        if ($PSCmdlet.ParameterSetName -eq "Names") {
            $resolvedIds = @()
            foreach ($itm in $TargetGroupNames) {
                try {
                    $tmp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object -Property DisplayName -eq $itm
                    if ($null -ne $tmp) {
                        $resolvedIds += $tmp.ObjectID
                    }
                    else {
                        $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Target group '$itm' not found" }
                        $hasError = $true
                    }
                }
                catch {
                    $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Target group '$itm' not found" }
                    $hasError = $true
                }
            }
            $GroupObjectIds = $resolvedIds

            if ($null -ne $UserNames) {
                $resolvedUserIds = @()
                foreach ($itm in $UserNames) {
                    try {
                        $tmp = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $itm) -or ($_.UserPrincipalName -eq $itm) }
                        if ($null -ne $tmp) { $resolvedUserIds += $tmp.ObjectID }
                        else {
                            $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$itm' not found" }
                            $hasError = $true
                        }
                    }
                    catch {
                        $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$itm' not found" }
                        $hasError = $true
                    }
                }
                $UserIds = $resolvedUserIds
            }

            if ($null -ne $GroupNames) {
                $resolvedGroupIds = @()
                foreach ($itm in $GroupNames) {
                    try {
                        $tmp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object -Property DisplayName -eq $itm
                        if ($null -ne $tmp) { $resolvedGroupIds += $tmp.ObjectID }
                        else {
                            $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$itm' not found" }
                            $hasError = $true
                        }
                    }
                    catch {
                        $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$itm' not found" }
                        $hasError = $true
                    }
                }
                $GroupIds = $resolvedGroupIds
            }
        }

        foreach ($gid in $GroupObjectIds) {
            try {
                $grp = Get-AzureADGroup -ObjectId $gid -ErrorAction Stop
            }
            catch {
                $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "GroupObjectID '$gid' $($_.Exception.Message)" }
                $hasError = $true
                continue
            }

            if ($null -ne $grp) {
                if ($null -ne $GroupIds) {
                    foreach ($itm in $GroupIds) {
                        try {
                            $addGrp = Get-AzureADGroup -ObjectId $itm -ErrorAction Stop
                        }
                        catch {
                            $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "GroupID '$itm' $($_.Exception.Message)" }
                            $hasError = $true
                            continue
                        }
                        if ($null -ne $addGrp) {
                            try {
                                $null = Add-AzureADGroupMember -ObjectId $gid -RefObjectId $itm -ErrorAction Stop
                                $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Group '$($addGrp.DisplayName)' added to Group '$($grp.DisplayName)'" }
                            }
                            catch {
                                $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "GroupID '$itm' $($_.Exception.Message)" }
                                $hasError = $true
                            }
                        }
                    }
                }
                if ($null -ne $UserIds) {
                    foreach ($itm in $UserIds) {
                        try {
                            $usr = Get-AzureADUser -ObjectId $itm -ErrorAction Stop
                        }
                        catch {
                            $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "UserID '$itm' $($_.Exception.Message)" }
                            $hasError = $true
                            continue
                        }
                        if ($null -ne $usr) {
                            try {
                                $null = Add-AzureADGroupMember -ObjectId $gid -RefObjectId $itm -ErrorAction Stop
                                $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User '$($usr.DisplayName)' added to Group '$($grp.DisplayName)'" }
                            }
                            catch {
                                $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "UserID '$itm' $($_.Exception.Message)" }
                                $hasError = $true
                            }
                        }
                    }
                }
            }
            else {
                $results += [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$gid' not found" }
                $hasError = $true
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
