#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits direct reports for a Microsoft Graph user

.DESCRIPTION
    Retrieves the list of users and contacts that report directly to the specifies Microsoft Graph user.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the manager whose direct reports are to be retrieved.

.EXAMPLE
    PS> ./Get-MgmtGraphUserDirectReport.ps1 -Identity "manager@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $reports = Get-MgUserDirectReportAsUser -UserId $Identity -All -ErrorAction Stop
        
        $results = foreach ($r in $reports) {
            [PSCustomObject]@{
                DisplayName       = $r.DisplayName
                UserPrincipalName = $r.UserPrincipalName
                Id                = $r.Id
                Mail              = $r.Mail
                JobTitle          = $r.JobTitle
                Department        = $r.Department
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
