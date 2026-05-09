#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Adds connection to a network-based printer.
.DESCRIPTION
    Adds a connection to a shared network printer using the PrintManagement module.
.PARAMETER ConnectionName
    Name of the shared printer to which to connect.
.EXAMPLE
    PS> ./Add-PrinterConnection.ps1 -ConnectionName "\\PrintServer\SharedPrinter"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionName
)

Process {
    try {
        Add-Printer -ConnectionName $ConnectionName -ErrorAction Stop | Out-Null
        Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Add printer connection: $ConnectionName succeeded"
    }
    catch { throw }
}
