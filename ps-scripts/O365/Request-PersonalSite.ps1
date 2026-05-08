#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Requests personal site creation for users
.DESCRIPTION
    Enqueues one or more users for OneDrive for Business personal site creation.
.PARAMETER UserEmails
    Comma-separated list of user email addresses (1 to 200 users)
.PARAMETER NoWait
    Continue executing immediately without polling status
.EXAMPLE
    PS> ./Request-PersonalSite.ps1 -UserEmails "user1@contoso.com,user2@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UserEmails,
    [switch]$NoWait
)

Process {
    try {
        $mails = $UserEmails.Split(',')
        $cmdArgs = @{ ErrorAction = 'Stop'; UserEmails = $mails; NoWait = $NoWait }
        $result = Request-SPOPersonalSite @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}