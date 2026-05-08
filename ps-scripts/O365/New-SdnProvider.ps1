#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Creates an SDN provider
.DESCRIPTION
    Registers a new software defined network provider.
.PARAMETER Identity
    Name of the SDN provider
.PARAMETER License
    License type
.EXAMPLE
    PS> ./New-SdnProvider.ps1 -Identity "MyProvider" -License "Premium"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [Parameter(Mandatory = $true)]
    [string]$License
)

Process {
    try {
        $result = New-SPOSdnProvider -Identity $Identity -License $License -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
