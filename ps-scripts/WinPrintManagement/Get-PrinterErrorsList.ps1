#Requires -Version 5.1

<#
.SYNOPSIS
    Print Management: Gets the error values of all local printers from the specified computer.
.DESCRIPTION
    Retrieves detailed error flags for all local printers on the specified computer using System.Printing.
.PARAMETER ComputerName
    Name of the computer from which to retrieve the printer errors.
.EXAMPLE
    PS> ./Get-PrinterErrorsList.ps1 -ComputerName "PC01"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
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
            $tsVal = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            foreach ($prn in $server.GetPrintQueues(@([System.Printing.EnumeratedPrintQueueTypes]::Local))) {
                $output += [PSCustomObject]@{
                    Timestamp = $tsVal
                    Printer = $prn.FullName
                    PagePunt = $prn.PagePunt
                    NeedUserIntervention = $prn.NeedUserIntervention
                    HasPaperProblem = $prn.HasPaperProblem
                    IsInError = $prn.IsInError
                    IsOutOfMemory = $prn.IsOutOfMemory
                    IsOutOfPaper = $prn.IsOutOfPaper
                    IsOutputBinFull = $prn.IsOutputBinFull
                    IsPaperJammed = $prn.IsPaperJammed
                    IsServerUnknown = $prn.IsServerUnknown
                }
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
