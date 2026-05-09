#Requires -Version 5.1

<#
.SYNOPSIS
    Print Management: Gets the status of a printer from the specified computer.
.DESCRIPTION
    Retrieves the operational status flags of a single printer using System.Printing.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer status.
.PARAMETER PrinterName
    Name of the printer from which to retrieve the status.
.EXAMPLE
    PS> ./Get-PrinterStatus.ps1 -ComputerName "PC01" -PrinterName "MyPrinter"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [string]$ComputerName
)

Process {
    try {
        [System.Reflection.Assembly]::LoadWithPartialName('System.Printing') | Out-Null
        $output = @()
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) {
            $server = New-Object System.Printing.LocalPrintServer
        }
        else {
            if (-not $ComputerName.StartsWith('\\')) { $ComputerName = '\\' + $ComputerName }
            $server = New-Object System.Printing.PrintServer($ComputerName)
        }
        if ($null -ne $server) {
            try { $que = $server.GetPrintQueue($PrinterName) } catch { $que = $null }
            if ($null -eq $que) {
                foreach ($prn in $server.GetPrintQueues(@([System.Printing.EnumeratedPrintQueueTypes]::Local))) {
                    if ($prn.FullName -eq $PrinterName -or $prn.Name -eq $PrinterName) { $que = $prn; break }
                }
            }
            if ($null -ne $que) {
                $tsVal = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsTonerLow'; Value = $que.IsTonerLow }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsPowerSaveOn'; Value = $que.IsPowerSaveOn }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsPrinting'; Value = $que.IsPrinting }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsProcessing'; Value = $que.IsProcessing }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsNotAvailable'; Value = $que.IsNotAvailable }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsOffline'; Value = $que.IsOffline }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsPaused'; Value = $que.IsPaused }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsBusy'; Value = $que.IsBusy }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'HasToner'; Value = $que.HasToner }
                $que.Dispose()
            }
            else {
                $output += [PSCustomObject]@{ Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); Message = "Printer $PrinterName not found on $ComputerName" }
            }
        }
        else {
            $output += [PSCustomObject]@{ Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); Message = "Print server $ComputerName not found" }
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $server) { $server.Dispose() } }
}
