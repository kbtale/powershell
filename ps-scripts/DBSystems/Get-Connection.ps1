#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    DBSystems: Lists active SimplySQL database connections

.DESCRIPTION
    Retrieves information about active database connections managed by the SimplySQL module. This script can return details for a specific named connection or list all active connections, providing structured data objects.

.PARAMETER ShowAll
    If set, returns all active SQL connections

.PARAMETER ConnectionName
    Specifies the name of the connection to retrieve (Defaults to 'DefaultConnection')

.EXAMPLE
    PS> ./Get-Connection.ps1 -ShowAll

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [switch]$ShowAll,
    [string]$ConnectionName = "DefaultConnection"
)

Import-Module SimplySQL

try {
    if ($ShowAll) {
        $result = Get-SqlConnection -All -ErrorAction Stop
    } else {
        $result = Get-SqlConnection -ConnectionName $ConnectionName -ErrorAction Stop
    }
    
    Write-Output $result
} catch {
    throw
}
