#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    DBSystems: Executes a SQL query using the SimplySQL module

.DESCRIPTION
    Executes a specified SQL statement against a database. This script can either use an existing named connection or establish a temporary one. It supports transaction management and returns the query results as structured objects.

.PARAMETER ServerName
    Specifies the name of the database server (ParameterSetName: NewConnection)

.PARAMETER DatabaseName
    Specifies the name of the database (ParameterSetName: NewConnection)

.PARAMETER SQLQuery
    Specifies the SQL statement to execute

.PARAMETER ConnectionName
    Specifies the name of the connection to use or create (Defaults to 'DefaultConnection')

.PARAMETER SQLCredential
    Specifies a PSCredential object for the connection

.PARAMETER ConnectionTimeout
    Specifies the timeout for establishing the connection in seconds

.PARAMETER CommandTimeout
    Specifies the timeout for the SQL statement execution in seconds

.PARAMETER UseTransaction
    Indicates whether to wrap the query in a SQL transaction (Rolls back on error)

.EXAMPLE
    PS> ./Invoke-Query.ps1 -ConnectionName "MyDatabase" -SQLQuery "SELECT * FROM Users"

.CATEGORY DBSystems
#>

[CmdLetBinding(DefaultParameterSetName = "ExistingConnection")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "NewConnection")]   
    [string]$ServerName, 

    [Parameter(Mandatory = $true, ParameterSetName = "NewConnection")]   
    [string]$DatabaseName, 

    [Parameter(Mandatory = $true, ParameterSetName = "NewConnection")]
    [Parameter(Mandatory = $true, ParameterSetName = "ExistingConnection")]
    [string]$SQLQuery,

    [Parameter(ParameterSetName = "NewConnection")]
    [Parameter(ParameterSetName = "ExistingConnection")]
    [string]$ConnectionName = "DefaultConnection",

    [Parameter(ParameterSetName = "NewConnection")]
    [PSCredential]$SQLCredential,

    [Parameter(ParameterSetName = "NewConnection")]
    [int32]$ConnectionTimeout = 30,

    [Parameter(ParameterSetName = "NewConnection")]
    [Parameter(ParameterSetName = "ExistingConnection")]
    [int32]$CommandTimeout = -1,

    [Parameter(ParameterSetName = "NewConnection")]
    [Parameter(ParameterSetName = "ExistingConnection")]
    [switch]$UseTransaction
)

Import-Module SimplySQL

try {
    # Manage Connection
    if ($PSCmdlet.ParameterSetName -eq "ExistingConnection") {
        if (-not (Test-SqlConnection -ConnectionName $ConnectionName)) {
            throw "Connection '$ConnectionName' not found or not active."
        }
    }
    else {
        [hashtable]$openArgs = @{
            'Server'         = $ServerName
            'Database'       = $DatabaseName
            'CommandTimeout' = $ConnectionTimeout
            'ConnectionName' = $ConnectionName
            'ErrorAction'    = 'Stop'
        }
        if ($null -ne $SQLCredential) {
            $openArgs.Add('Credential', $SQLCredential)
        }
        Open-SqlConnection @openArgs | Out-Null
    }
    
    if ($UseTransaction) {
        try {
            Start-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
            $result = Invoke-SqlQuery -ConnectionName $ConnectionName -Query $SQLQuery -CommandTimeout $CommandTimeout -ErrorAction Stop
            Complete-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
        }
        catch {
            Undo-SqlTransaction -ConnectionName $ConnectionName -ErrorAction Stop
            throw
        }
    }
    else {
        $result = Invoke-SqlQuery -ConnectionName $ConnectionName -Query $SQLQuery -CommandTimeout $CommandTimeout -ErrorAction Stop
    }
    
    Write-Output $result
}
catch {
    throw
}
finally {
    if ($PSCmdlet.ParameterSetName -eq "NewConnection") {
        Close-SqlConnection -ConnectionName $ConnectionName 
    }
}
