#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Gets SQL Server error logs

.DESCRIPTION
    Retrieves the SQL Server error logs. Supports filtering by date range (Before/After) or by predefined periods (Since Yesterday, Last Week, etc.).

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER Ascending
    Indicates that the cmdlet sorts the collection of error logs by the log date in ascending order

.PARAMETER After
    Specifies that this cmdlet only gets error logs generated after the given time

.PARAMETER Before
    Specifies that this cmdlet only gets error logs generated before the given time
        
.PARAMETER Since
    Specifies an abbreviation for the Timespan parameter

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER Properties
    List of properties to expand, comma separated e.g. Name,Status. Use * for all properties

.EXAMPLE
    PS> ./Get-ErrorLog.ps1 -ServerInstance "localhost\SQLEXPRESS" -Since Yesterday

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [datetime]$After,
    [datetime]$Before,
    [switch]$Ascending,
    [ValidateSet('Midnight', 'Yesterday', 'LastWeek','LastMonth')]
    [string]$Since,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Date','Source','Text','ServerInstance')]
    [string[]]$Properties = @('Date','Source','Text','ServerInstance')
)

function Get-SqlServerInstanceInternal {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $true)]   
        [string]$ServerInstance,    
        [pscredential]$ServerCredential,
        [int]$ConnectionTimeout = 30
    )
    try {
        [hashtable]$cmdArgs = @{
            'ErrorAction' = 'Stop'
            'Confirm' = $false
            'ServerInstance' = $ServerInstance
            'ConnectionTimeout' = $ConnectionTimeout
        }
        if ($null -ne $ServerCredential) {
            $cmdArgs.Add('Credential', $ServerCredential)
        }
        return Get-SqlInstance @cmdArgs
    } catch {
        throw
    }
}

Import-Module SQLServer

try {
    if ($Properties -contains '*') {
        $Properties = @('*')
    }
    
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'Ascending' = $Ascending.ToBool()
    }
    
    if ($null -ne $After) {
        $cmdArgs.Add("After", $After)
    }
    if ($null -ne $Before) {
        $cmdArgs.Add("Before", $Before)
    }
    if (-not $After -and -not $Before -and -not [string]::IsNullOrWhiteSpace($Since)) {
        $cmdArgs.Add("Since", $Since)
    }  
    
    $result = Get-SqlErrorLog @cmdArgs | Select-Object $Properties
    Write-Output $result
} catch {
    throw
}
