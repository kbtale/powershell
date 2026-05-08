#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Lists all distribution groups
.DESCRIPTION
    Retrieves all Universal distribution groups from Exchange Online.
.EXAMPLE
    PS> ./Get-DistributionGroup.ps1
.CATEGORY O365
#>

Process {
    try {
        $groups = Get-DistributionGroup -ErrorAction Stop | Select-Object *

        if ($null -eq $groups -or $groups.Count -eq 0) {
            Write-Output "No distribution groups found"
            return
        }

        foreach ($g in $groups) {
            $g | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
