#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Enables or disables Briefing email for a user
.DESCRIPTION
    Enables or disables the Briefing email for a specified user.
.PARAMETER Identity
    The user to modify (e.g., user@domain.com)
.PARAMETER Enabled
    Enable or disable the Briefing email for the user
.EXAMPLE
    PS> ./Set-EXOUserBriefingConfig.ps1 -Identity "user@domain.com" -Enabled $true
.EXAMPLE
    PS> ./Set-EXOUserBriefingConfig.ps1 -Identity "user@domain.com" -Enabled $false
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [bool]$Enabled
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity; 'Enabled' = $Enabled}

        $result = Set-UserBriefingConfig @cmdArgs | Select-Object *
        if ($null -eq $result) {
            Write-Output "Briefing configuration updated"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
    }
    catch { throw }
}
