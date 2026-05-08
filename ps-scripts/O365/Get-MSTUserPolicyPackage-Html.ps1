#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of user's assigned policy package
.DESCRIPTION
    Generates an HTML report with the policy package assigned to a specific user.
.PARAMETER Identity
    The user that will get their assigned policy package
.EXAMPLE
    PS> ./Get-MSTUserPolicyPackage-Html.ps1 -Identity "user@domain.com" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        $packages = Get-CsUserPolicyPackage @getArgs | Select-Object Name, Description, PackageType, RecommendationType
        $result = @()
        foreach ($pkg in $packages) {
            $result += [PSCustomObject]@{
                Name               = $pkg.Name
                Description        = $pkg.Description
                PackageType        = $pkg.PackageType
                RecommendationType = $pkg.RecommendationType
                Policies           = if ($null -ne $pkg.Policies) { ($pkg.Policies.Keys -join '; ') } else { '' }
            }
        }

        if ($result.Count -eq 0) {
            Write-Output "No policy package assigned"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
