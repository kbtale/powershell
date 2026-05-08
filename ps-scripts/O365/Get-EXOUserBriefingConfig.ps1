#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets the Briefing email configuration for a user
.DESCRIPTION
    Retrieves the current state of the Briefing email flag for the specified user.
.PARAMETER Identity
    The user to view the Briefing configuration for (e.g., user@domain.com)
.EXAMPLE
    PS> ./Get-EXOUserBriefingConfig.ps1 -Identity "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        $result = Get-UserBriefingConfig @cmdArgs | Select-Object *
        if ($null -eq $result) {
            Write-Output "No Briefing configuration found"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
