#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Gets all printer drivers from the computer.
.DESCRIPTION
    Retrieves all printer drivers from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer drivers.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER Properties
    List of properties to expand; use * for all properties.
.EXAMPLE
    PS> ./Get-PrinterDrivers.ps1 -ComputerName "PC01"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [ValidateSet('*', 'Name', 'Description', 'InfPath', 'ConfigFile', 'MajorVersion', 'PrinterEnvironment', 'PrintProcessor')]
    [string[]]$Properties = @('Name', 'Description', 'InfPath', 'ConfigFile', 'MajorVersion', 'PrinterEnvironment', 'PrintProcessor')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $drivers = Get-PrinterDriver -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop |
            Select-Object $Properties | Sort-Object Name
        $drivers | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $drivers
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
