#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Apply a policy package to users
.DESCRIPTION
    Applies a policy package to one or more users in the tenant and returns the updated policy assignments.
.PARAMETER Users
    A list of one or more users in the tenant
.PARAMETER PackageName
    The name of the policy package to apply
.EXAMPLE
    PS> ./Grant-MSTUserPolicyPackage.ps1 -Users @("user1@domain.com","user2@domain.com") -PackageName "Education_Teacher"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string[]]$Users,
    [Parameter(Mandatory = $true)]
    [string]$PackageName
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'PackageName' = $PackageName; 'Identity' = $Users}
        $null = Grant-CsUserPolicyPackage @cmdArgs

        $result = @()
        foreach ($usr in $Users) {
            $pkgs = Get-CsUserPolicyPackage -Identity $usr -ErrorAction Stop | Select-Object *
            $result += [PSCustomObject]@{
                Timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                User        = $usr
                PackageName = $PackageName
                Status      = 'Policy package applied'
            }
            if ($null -ne $pkgs) {
                $result += $pkgs
            }
        }

        Write-Output $result
    }
    catch { throw }
}
