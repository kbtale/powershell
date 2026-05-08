#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Assign a policy package to a group
.DESCRIPTION
    Assigns a policy package to one or more groups in the tenant. Supports optional policy rankings.
.PARAMETER GroupId
    One or more group IDs in the tenant
.PARAMETER PackageName
    The name of the policy package to apply
.PARAMETER PolicyRankings
    Policy rankings for each of the policy types in the package
.EXAMPLE
    PS> ./Grant-MSTGroupPolicyPackageAssignment.ps1 -GroupId @("group-id") -PackageName "Education_Teacher"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string[]]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [string]$PolicyRankings
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'PackageName' = $PackageName; 'GroupId' = $GroupId}

        if ($PSBoundParameters.ContainsKey('PolicyRankings')) {
            $cmdArgs.Add('PolicyRankings', $PolicyRankings)
        }

        $result = Grant-CsGroupPolicyPackageAssignment @cmdArgs

        [PSCustomObject]@{
            Timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            GroupId     = ($GroupId -join ', ')
            PackageName = $PackageName
            Status      = if ($null -eq $result) { 'Policy package assigned' } else { $result.ToString() }
        }
    }
    catch { throw }
}
