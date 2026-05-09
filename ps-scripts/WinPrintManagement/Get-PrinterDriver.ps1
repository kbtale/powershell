#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Gets the specified printer driver from the computer.
.DESCRIPTION
    Retrieves a specific printer driver from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer driver.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER DriverName
    Name of the printer driver to retrieve.
.PARAMETER Properties
    List of properties to expand; use * for all properties.
.EXAMPLE
    PS> ./Get-PrinterDriver.ps1 -ComputerName "PC01" -DriverName "HP Universal Printing PCL 6"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DriverName,
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
        $driver = Get-PrinterDriver -CimSession $cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop |
            Select-Object $Properties | Sort-Object Name
        $driver | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $driver
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
