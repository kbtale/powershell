#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of all policy packages available
.DESCRIPTION
    Generates an HTML report with all policy packages available on the tenant.
.PARAMETER Identity
    The name of a specific policy package to retrieve
.EXAMPLE
    PS> ./Get-MSTPolicyPackage-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTPolicyPackage-Html.ps1 -Identity "Education_Teacher" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$Identity
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}

        if (-not [System.String]::IsNullOrWhiteSpace($Identity)) {
            $getArgs.Add('Identity', $Identity)
        }

        $packages = Get-CsPolicyPackage @getArgs | Select-Object Name, Description, PackageType
        $result = @()
        foreach ($pkg in $packages) {
            $result += [PSCustomObject]@{
                Name        = $pkg.Name
                Description = $pkg.Description
                PackageType = $pkg.PackageType
            }
        }

        if ($result.Count -eq 0) {
            Write-Output "No policy packages found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
