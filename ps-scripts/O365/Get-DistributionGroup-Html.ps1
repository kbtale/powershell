#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: HTML report of universal distribution groups
.DESCRIPTION
    Generates an HTML report of all universal distribution groups in Exchange Online.
.EXAMPLE
    PS> ./Get-DistributionGroup-Html.ps1 | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        [string[]]$Properties = @('Name','DisplayName','Alias','GroupType','OrganizationalUnit','SamAccountName','AddressListMembership')
        $res = Get-DistributionGroup -ErrorAction Stop | Select-Object $Properties | Sort-Object Name

        if ($null -eq $res -or $res.Count -eq 0) {
            Write-Output "No distribution groups found"
            return
        }

        Write-Output ($res | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
