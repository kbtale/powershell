#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Gets the specified printer port from the computer.
.DESCRIPTION
    Retrieves a specific printer port from the specified computer using the PrintManagement module.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer port.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PortName
    Name of the printer port to retrieve.
.PARAMETER Properties
    List of properties to expand; use * for all properties.
.EXAMPLE
    PS> ./Get-PrinterPort.ps1 -ComputerName "PC01" -PortName "LPT1:"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PortName,
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [ValidateSet('*', 'Caption', 'Description', 'Status', 'Name')]
    [string[]]$Properties = @('Caption', 'Description', 'Status')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        elseif ($null -eq ($Properties | Where-Object { $_ -like 'Name' })) { $Properties += 'Name' }
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $port = Get-PrinterPort -CimSession $cim -ComputerName $ComputerName -Name $PortName -ErrorAction Stop |
            Select-Object $Properties | Sort-Object Name
        $port | ForEach-Object { $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru }
        Write-Output $port
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
