#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Retrieves a list of printer ports installed on the specified computer.
.DESCRIPTION
    Retrieves all printer ports from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer ports.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER Properties
    List of properties to expand; use * for all properties.
.EXAMPLE
    PS> ./Get-PrinterPorts.ps1 -ComputerName "PC01"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [ValidateSet('*', 'Caption', 'Name', 'Description', 'Status')]
    [string[]]$Properties = @('Caption', 'Name', 'Description', 'Status')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        elseif ($null -eq ($Properties | Where-Object { $_ -like 'Name' })) { $Properties += 'Name' }
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $ports = Get-PrinterPort -CimSession $cim -ComputerName $ComputerName -ErrorAction Stop |
            Select-Object $Properties | Sort-Object Name
        $ports | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $ports
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
