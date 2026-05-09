#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Installs a local, TCP, LPR or TCP LPR printer port on the specified computer.
.DESCRIPTION
    Installs a printer port on the specified computer supporting Local, TCP, LPR, and TCP LPR port types.
.PARAMETER ComputerName
    Name of the computer to which to add the printer port.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PortName
    Name of the printer port (Local, TCP Port, TCP LPR Port).
.PARAMETER HostName
    Host name of the computer on which to add an LPR printer port.
.PARAMETER PrinterName
    Name of the printer installed on the LPR printer port.
.PARAMETER PrinterHostAddress
    Host address of the TCP/IP printer port.
.PARAMETER PortNumber
    TCP/IP port number for the printer port.
.PARAMETER LprHostAddress
    LPR host address when installing a TCP/IP printer port in LPR mode.
.PARAMETER LprQueueName
    LPR queue name when installing a TCP/IP printer port in LPR mode.
.PARAMETER SNMP
    Enables SNMP and specifies the index for TCP/IP printer port management.
.PARAMETER SNMPCommunity
    SNMP community name for TCP/IP printer port management.
.EXAMPLE
    PS> ./Add-PrinterPort.ps1 -ComputerName "PC01" -PortName "192.168.1.100" -PrinterHostAddress "192.168.1.100" -PortNumber 9100
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Local')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TCP Port')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TCP LPR Port')]
    [string]$PortName,
    [Parameter(Mandatory = $true, ParameterSetName = 'LPR Port')]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = 'LPR Port')]
    [string]$PrinterName,
    [Parameter(Mandatory = $true, ParameterSetName = 'TCP Port')]
    [string]$PrinterHostAddress,
    [Parameter(Mandatory = $true, ParameterSetName = 'TCP Port')]
    [int]$PortNumber,
    [Parameter(Mandatory = $true, ParameterSetName = 'TCP LPR Port')]
    [string]$LprHostAddress,
    [Parameter(Mandatory = $true, ParameterSetName = 'TCP LPR Port')]
    [string]$LprQueueName,
    [Parameter(ParameterSetName = 'TCP Port')]
    [Parameter(ParameterSetName = 'TCP LPR Port')]
    [int]$SNMP,
    [Parameter(ParameterSetName = 'TCP Port')]
    [Parameter(ParameterSetName = 'TCP LPR Port')]
    [string]$SNMPCommunity,
    [Parameter(ParameterSetName = 'Local')]
    [Parameter(ParameterSetName = 'LPR Port')]
    [Parameter(ParameterSetName = 'TCP Port')]
    [Parameter(ParameterSetName = 'TCP LPR Port')]
    [string]$ComputerName,
    [Parameter(ParameterSetName = 'Local')]
    [Parameter(ParameterSetName = 'LPR Port')]
    [Parameter(ParameterSetName = 'TCP Port')]
    [Parameter(ParameterSetName = 'TCP LPR Port')]
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $cmdArgs = @{
            ErrorAction = 'Stop'
            CimSession = $cim
            ComputerName = $ComputerName
        }
        $port = $null
        if ($PSCmdlet.ParameterSetName -eq 'Local') {
            $cmdArgs.Add('Name', $PortName)
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'LPR Port') {
            $cmdArgs.Add('HostName', $HostName)
            $cmdArgs.Add('PrinterName', $PrinterName)
            Add-PrinterPort @cmdArgs | Out-Null
            $port = Get-PrinterPort -Name $PrinterName
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'TCP Port') {
            $cmdArgs.Add('PrinterHostAddress', $PrinterHostAddress)
            $cmdArgs.Add('Name', $PortName)
            $cmdArgs.Add('PortNumber', $PortNumber)
            if (-not [System.String]::IsNullOrWhiteSpace($SNMPCommunity) -and $SNMP -gt 0) {
                $cmdArgs.Add('SNMP', $SNMP)
                $cmdArgs.Add('SNMPCommunity', $SNMPCommunity)
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'TCP LPR Port') {
            $cmdArgs.Add('LprHostAddress', $LprHostAddress)
            $cmdArgs.Add('Name', $PortName)
            $cmdArgs.Add('LprQueueName', $LprQueueName)
            if (-not [System.String]::IsNullOrWhiteSpace($SNMPCommunity) -and $SNMP -gt 0) {
                $cmdArgs.Add('SNMP', $SNMP)
                $cmdArgs.Add('SNMPCommunity', $SNMPCommunity)
            }
        }
        if ($null -eq $port) {
            Add-PrinterPort @cmdArgs | Out-Null
            $port = Get-PrinterPort -Name $PortName
        }
        $port | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru
        Write-Output $port
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
