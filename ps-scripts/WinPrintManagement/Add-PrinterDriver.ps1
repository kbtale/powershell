#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Installs a printer driver on the specified computer.
.DESCRIPTION
    Installs a printer driver on the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer on which to install the printer driver.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER DriverName
    Name of the printer driver to install.
.PARAMETER InfFilePath
    Path of the printer driver INF file in the driver store.
.EXAMPLE
    PS> ./Add-PrinterDriver.ps1 -ComputerName "PC01" -DriverName "HP Universal Printing PCL 6"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DriverName,
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [string]$InfFilePath
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('InfFilePath')) {
            Add-PrinterDriver -CimSession $cim -Name $DriverName -ComputerName $ComputerName -InfPath $InfFilePath -ErrorAction Stop
        }
        else {
            Add-PrinterDriver -CimSession $cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop
        }
        $driver = Get-PrinterDriver -CimSession $cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop |
            Select-Object Name, Description, InfPath, ConfigFile, MajorVersion, PrinterEnvironment, PrintProcessor
        $driver | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $driver
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
