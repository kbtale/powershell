#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets taxonomy replication parameters
.DESCRIPTION
    Configures multi-geo taxonomy replication by selecting term groups.
.PARAMETER ReplicatedGroups
    Comma-separated list of term group names to replicate; omit to replicate all
.EXAMPLE
    PS> ./Set-TenantTaxonomyReplicationParameters.ps1 -ReplicatedGroups "People,Products"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$ReplicatedGroups
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ReplicatedGroups')) {
            $grps = $ReplicatedGroups.Split(',')
            $cmdArgs.Add('ReplicatedGroups', $grps)
        }
        else {
            $cmdArgs.Add('ReplicateAllGroups', $null)
        }
        $result = Set-SPOTenantTaxonomyReplicationParameters @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}