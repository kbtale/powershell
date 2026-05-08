#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets taxonomy replication parameters
.DESCRIPTION
    Retrieves the multi-geo taxonomy replication parameters.
.EXAMPLE
    PS> ./Get-TenantTaxonomyReplicationParameters.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOTenantTaxonomyReplicationParameters -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}