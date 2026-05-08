#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Lists all resource mailboxes
.DESCRIPTION
    Retrieves all resource mailboxes from Exchange Online, sorted by display name.
.EXAMPLE
    PS> ./Get-Resources.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        $res = Get-Mailbox -SortBy DisplayName -ErrorAction Stop | Select-Object * | Where-Object -Property IsResource -EQ $true
        if ($null -eq $res -or $res.Count -eq 0) {
            Write-Output "No resources found"
            return
        }
        foreach ($item in $res) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
