#Requires -Version 5.1

<#
.SYNOPSIS
    Print Management: Gets the error values of a printer from the specified computer.
.DESCRIPTION
    Retrieves detailed error flags of a single printer using System.Printing.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer errors.
.PARAMETER PrinterName
    Name of the printer from which to retrieve the error values.
.EXAMPLE
    PS> ./Get-PrinterErrors.ps1 -ComputerName "PC01" -PrinterName "MyPrinter"
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
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'PagePunt'; Value = $que.PagePunt }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'NeedUserIntervention'; Value = $que.NeedUserIntervention }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'HasPaperProblem'; Value = $que.HasPaperProblem }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsInError'; Value = $que.IsInError }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsOutOfMemory'; Value = $que.IsOutOfMemory }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsOutOfPaper'; Value = $que.IsOutOfPaper }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsOutputBinFull'; Value = $que.IsOutputBinFull }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsPaperJammed'; Value = $que.IsPaperJammed }
                $output += [PSCustomObject]@{ Timestamp = $tsVal; Property = 'IsServerUnknown'; Value = $que.IsServerUnknown }
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
