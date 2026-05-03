#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Configures the authentication mode of a SQL Server instance

.DESCRIPTION
    Configures the authentication mode (Normal, Integrated, or Mixed) for a SQL Server instance. This script handles service restart options and provides a way to manage security settings across multiple servers.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER Mode
    Specifies the authentication mode that will be configured: Normal, Integrated, or Mixed

.PARAMETER AutomaticallyAcceptUntrustedCertificates
    Indicates that this cmdlet automatically accepts untrusted certificates

.PARAMETER ForceServiceRestart
    Indicates that this cmdlet forces the SQL Server service to restart, if necessary, without prompting the user
    
.PARAMETER ManagementPublicPort
    Specifies the public management port on the target computer

.PARAMETER NoServiceRestart
    Indicates that this cmdlet prevents a restart of the SQL Server service without prompting the user

.PARAMETER RetryTimeout
    Specifies the time period to retry the command on the target sever

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Set-AuthenticationMode.ps1 -ServerInstance "localhost\SQLEXPRESS" -Mode Mixed -ForceServiceRestart

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [pscredential]$ServerCredential,
    [ValidateSet('Normal', 'Integrated', 'Mixed')]
    [string]$Mode = 'Normal',
    [switch]$AutomaticallyAcceptUntrustedCertificates,
    [switch]$ForceServiceRestart,
    [int]$ManagementPublicPort,
    [switch]$NoServiceRestart,
    [int]$RetryTimeout,
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
        'Credential' = $ServerCredential
        'Mode' = $Mode
        'Confirm' = $false
        'NoServiceRestart' = $NoServiceRestart.ToBool()
        'ForceServiceRestart' = $ForceServiceRestart
        'AutomaticallyAcceptUntrustedCertificates' = $AutomaticallyAcceptUntrustedCertificates.ToBool()
    }
    
    if ($ManagementPublicPort -gt 0) {
        $cmdArgs.Add("ManagementPublicPort", $ManagementPublicPort)
    }
    if ($RetryTimeout -gt 0) {
        $cmdArgs.Add("RetryTimeout", $RetryTimeout)
    }
    
    $result = Set-SqlAuthenticationMode @cmdArgs
    Write-Output $result
} catch {
    throw
}
