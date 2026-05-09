#Requires -Version 5.1

<#
.SYNOPSIS
    Print Management: Sets the default printer
.DESCRIPTION
    Sets a printer as the default printer using .NET or WMI.
.PARAMETER PrinterName
    Full name of the printer to set as default
.PARAMETER UseWmi
    Use WMI instead of .NET to set the default printer
.EXAMPLE
    PS> ./Set-DefaultPrinter.ps1 -PrinterName "HP LaserJet"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [switch]$UseWmi
)

Process {
    try {
        if ($UseWmi) {
            $prObj = Get-CimInstance -Class Win32_Printer -Filter "Name='$PrinterName'" -ErrorAction Stop
            if ($null -eq $prObj) { throw "Printer '$PrinterName' not found" }
            Invoke-CimMethod -InputObject $prObj -MethodName SetDefaultPrinter -ErrorAction Stop | Out-Null
        }
        else {
            [System.Reflection.Assembly]::LoadWithPartialName('System.Printing') | Out-Null
            $quTypes = @([System.Printing.EnumeratedPrintQueueTypes]::Connections, [System.Printing.EnumeratedPrintQueueTypes]::Local)
            $prs = New-Object System.Printing.PrintServer
            $col = $prs.GetPrintQueues($quTypes)
            $prQueue = $col | Where-Object { $_.FullName -eq $PrinterName }
            if ($null -eq $prQueue) { throw "Printer '$PrinterName' not found" }
            $localPS = New-Object System.Printing.LocalPrintServer
            $localPS.DefaultPrintQueue = [System.Printing.PrintQueue]$prQueue
            $localPS.Commit()
            $localPS.Dispose()
            $prQueue.Dispose()
            $col.Dispose()
            $prs.Dispose()
        }
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; PrinterName = $PrinterName; Message = "Printer '$PrinterName' set as default" }
    }
    catch { throw }
}
