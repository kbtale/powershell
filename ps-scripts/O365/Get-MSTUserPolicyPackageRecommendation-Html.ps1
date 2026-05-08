#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of user policy package recommendations
.DESCRIPTION
    Generates an HTML report with policy package recommendations for a specific user.
.PARAMETER Identity
    The user that will receive policy package recommendations
.EXAMPLE
    PS> ./Get-MSTUserPolicyPackageRecommendation-Html.ps1 -Identity "user@domain.com" | Out-File report.html
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

        $packages = Get-CsUserPolicyPackageRecommendation @getArgs | Select-Object Name, Description, PackageType, RecommendationType
        $result = @()
        foreach ($pkg in $packages) {
            $result += [PSCustomObject]@{
                Name               = $pkg.Name
                Description        = $pkg.Description
                PackageType        = $pkg.PackageType
                RecommendationType = $pkg.RecommendationType
            }
        }

        if ($result.Count -eq 0) {
            Write-Output "No policy package recommendations found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
