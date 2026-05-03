#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Tests the health of Smart Admin by evaluating SQL Server PBM policies

.DESCRIPTION
    Evaluates the health of SQL Server Smart Admin by running Policy-Based Management (PBM) checks. This script helps identify issues with managed backups and other automated administrative tasks.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
    
.PARAMETER DatabaseName
    Specifies the name of the database for the Smart Admin health check

.PARAMETER AllowUserPolicies
    Indicates that this cmdlet runs user policies found in the Smart Admin warning and error policy categories

.PARAMETER NoRefresh
    Indicates that this cmdlet will not manually refresh the target object

.PARAMETER ShowPolicyDetails
    Indicates that this cmdlet shows the detailed result of the policy evaluation

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Test-SmartAdmin.ps1 -ServerInstance "localhost\SQLEXPRESS" -ShowPolicyDetails

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DatabaseName,
    [switch]$AllowUserPolicies,
    [switch]$NoRefresh,
    [switch]$ShowPolicyDetails,
    [int]$ConnectionTimeout = 30
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
    $instance = Get-SqlServerInstanceInternal -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{
        'ErrorAction' = 'Stop'
        'InputObject' = $instance
        'Confirm' = $false
    }
    if (-not [string]::IsNullOrWhiteSpace($DatabaseName)) {
        $cmdArgs.Add('DatabaseName', $DatabaseName)
    }
    
    $smartAdmin = Get-SqlSmartAdmin @cmdArgs
    $result = $smartAdmin | Test-SqlSmartAdmin -AllowUserPolicies:$AllowUserPolicies -NoRefresh:$NoRefresh -ShowPolicyDetails:$ShowPolicyDetails -Confirm:$false -ErrorAction Stop
    
    Write-Output $result
} catch {
    throw
}
