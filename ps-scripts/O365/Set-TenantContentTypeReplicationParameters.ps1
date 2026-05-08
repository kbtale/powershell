#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets content type replication parameters
.DESCRIPTION
    Configures multi-geo content type replication by selecting content types.
.PARAMETER ReplicatedContentTypes
    Comma-separated list of content type names to replicate; omit to replicate all
.EXAMPLE
    PS> ./Set-TenantContentTypeReplicationParameters.ps1 -ReplicatedContentTypes "Document,Event"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$ReplicatedContentTypes
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ReplicatedContentTypes')) {
            $tmp = $ReplicatedContentTypes.Split(',')
            $cmdArgs.Add('ReplicatedContentTypes', $tmp)
        }
        else {
            $cmdArgs.Add('ReplicateAllContentTypes', $null)
        }
        $result = Set-SPOTenantContentTypeReplicationParameters @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}