#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    DBSystems: Closes an existing SimplySQL database connection

.DESCRIPTION
    Closes a specified database connection managed by the SimplySQL module. This script provides a standardized way to decommission named connections and release database resources.

.PARAMETER ConnectionName
    Specifies the name of the connection to close (Defaults to 'DefaultConnection')

.EXAMPLE
    PS> ./Close-Connection.ps1 -ConnectionName "MyDatabase"

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [string]$ConnectionName = "DefaultConnection"
)

Import-Module SimplySQL

try {
    $status = "Connection '$ConnectionName' not found or already closed."
    if (Test-SqlConnection -ConnectionName $ConnectionName) {
        Close-SqlConnection -ConnectionName $ConnectionName 
        $status = "Connection '$ConnectionName' successfully closed."
    }
    
    Write-Output $status
} catch {
    throw
}
