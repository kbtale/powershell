#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    DBSystems: Adds a Windows Firewall rule for a SQL Server instance

.DESCRIPTION
    Adds a Windows Firewall rule to allow connections to a specific SQL Server instance. This script simplifies remote connectivity management by providing a standardized way to configure firewall exceptions across multiple servers.

.PARAMETER ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.PARAMETER ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.PARAMETER ManagementPublicPort
    Specifies the public management port on the target machine

.PARAMETER RetryTimeout
    Specifies the time period to retry the command on the target server

.PARAMETER AutomaticallyAcceptUntrustedCertificates
    Indicates that this cmdlet automatically accepts untrusted certificates

.PARAMETER ConnectionTimeout
    Specifies the time period to retry the command on the target server

.EXAMPLE
    PS> ./Add-FirewallRule.ps1 -ServerInstance "localhost\SQLEXPRESS" -AutomaticallyAcceptUntrustedCertificates

.CATEGORY DBSystems
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)] 
    [pscredential]$ServerCredential,
    [int]$RetryTimeout,
    [int]$ManagementPublicPort,
    [switch]$AutomaticallyAcceptUntrustedCertificates,
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
        'InputObject'  = $instance
        'Credential'   = $ServerCredential
        'AutomaticallyAcceptUntrustedCertificates' = $AutomaticallyAcceptUntrustedCertificates.ToBool()
        'Confirm'      = $false
    }
    
    if ($ManagementPublicPort -gt 0) {
        $cmdArgs.Add('ManagementPublicPort', $ManagementPublicPort)
    }
    if ($RetryTimeout -gt 0) {
        $cmdArgs.Add('RetryTimeout', $RetryTimeout)
    }
    
    Add-SqlFirewallRule @cmdArgs
    Write-Output "Successfully added firewall rule for instance '$ServerInstance'."
} catch {
    throw
}
