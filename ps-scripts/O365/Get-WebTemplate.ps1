#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets web templates
.DESCRIPTION
    Returns the available web templates in the tenant.
.EXAMPLE
    PS> ./Get-WebTemplate.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOWebTemplate -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
