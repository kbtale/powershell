#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a migration job
.DESCRIPTION
    Deletes a SharePoint migration job.
.PARAMETER PackageId
    The migration package ID
.EXAMPLE
    PS> ./Remove-MigrationJob.ps1 -PackageId "guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [guid]$PackageId
)

Process {
    try {
        Remove-SPOMigrationJob -PackageId $PackageId -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Migration job '$PackageId' removed" }
    }
    catch { throw }
}
