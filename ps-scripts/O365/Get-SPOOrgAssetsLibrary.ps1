#Requires -Version 5.1

<#
.SYNOPSIS
    SharePoint Online: Displays information about all libraries designated as locations for organization assets
.DESCRIPTION
    Displays information about all libraries designated as locations for organization assets

.EXAMPLE
    PS> ./Get-SPOOrgAssetsLibrary.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param(

)

Process {
    try {
        $result = Get-SPOOrgAssetsLibrary -ErrorAction Stop | Select-Object *
                Write-Output $result

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No results found"; return }
        foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force }
    }
    catch { throw }
}