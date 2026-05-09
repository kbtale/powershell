#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Gets the configuration information of a printer.
.DESCRIPTION
    Retrieves printer configuration (collate, color, duplex, paper size) from the specified printer.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer configuration.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PrinterName
    Name of the printer from which to retrieve the configuration information.
.EXAMPLE
    PS> ./Get-PrintConfiguration.ps1 -ComputerName "PC01" -PrinterName "MyPrinter"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $conf = Invoke-CimMethod -CimSession $cim -ClassName MSFT_PrinterConfiguration -Namespace 'ROOT/StandardCimv2' `
            -MethodName GetByPrinterName -Arguments @{ PrinterName = $PrinterName } |
            ForEach-Object CmdletOutput
        $conf | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru
        Write-Output $conf
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
