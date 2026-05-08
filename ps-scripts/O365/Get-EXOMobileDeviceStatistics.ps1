#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets mobile device statistics for a user mailbox
.DESCRIPTION
    Retrieves the list of mobile devices configured to synchronize with a specified user's mailbox using the EXO V2 module.
.PARAMETER Mailbox
    Filters results by the user mailbox (GUID, User ID or UPN) associated with the mobile device
.PARAMETER ActiveSync
    Filters results by Exchange ActiveSync devices
.PARAMETER OWAforDevices
    Filters results by devices where Outlook on the web for devices is enabled
.PARAMETER RestApi
    Filters results by REST API devices
.PARAMETER UniversalOutlook
    Filters results by Mail and Calendar devices
.EXAMPLE
    PS> ./Get-EXOMobileDeviceStatistics.ps1 -Mailbox "user@domain.com"
.EXAMPLE
    PS> ./Get-EXOMobileDeviceStatistics.ps1 -Mailbox "user@domain.com" -ActiveSync
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Mailbox,
    [switch]$ActiveSync,
    [switch]$OWAforDevices,
    [switch]$RestApi,
    [switch]$UniversalOutlook
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Mailbox' = $Mailbox; 'ActiveSync' = $ActiveSync; 'OWAforDevices' = $OWAforDevices; 'RestApi' = $RestApi; 'UniversalOutlook' = $UniversalOutlook}

        $result = Get-EXOMobileDeviceStatistics @cmdArgs | Select-Object *
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No mobile device statistics found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
