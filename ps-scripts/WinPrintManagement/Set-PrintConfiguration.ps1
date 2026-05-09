#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Updates printer configuration
.DESCRIPTION
    Modifies printer configuration settings.
.PARAMETER PrinterName
    Printer to configure
.PARAMETER Comment
    New comment
.PARAMETER Location
    New location
.PARAMETER Shared
    Share/unshare the printer
.PARAMETER ComputerName
    Computer hosting the printer
.PARAMETER AccessAccount
    Optional credential
.EXAMPLE
    PS> ./Set-PrintConfiguration.ps1 -PrinterName "HP LaserJet" -Comment "Floor 3" -Shared $true
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$PrinterName,
    [string]$Comment,
    [string]$Location,
    [bool]$Shared,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop } else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $cmdArgs = @{ ErrorAction = 'Stop'; CimSession = $cim; ComputerName = $ComputerName; Name = $PrinterName; Confirm = $false }
        if ($PSBoundParameters.ContainsKey('Comment')) { $cmdArgs.Add('Comment', $Comment) }
        if ($PSBoundParameters.ContainsKey('Location')) { $cmdArgs.Add('Location', $Location) }
        if ($PSBoundParameters.ContainsKey('Shared')) { $cmdArgs.Add('Shared', $Shared) }
        $result = Set-Printer @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
