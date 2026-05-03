#Requires -Version 5.1
#Requires -Modules NetTCPIP

<#
.SYNOPSIS
    Windows: Tests TCP connectivity to a specific port on a remote host

.DESCRIPTION
    Performs a TCP port connection test from the local machine or a remote computer to a target destination. Useful for verifying firewall rules and service availability.

.PARAMETER Destination
    Specifies the hostname or IP address of the target machine to test.

.PARAMETER Port
    Specifies the TCP port number to test.

.PARAMETER ComputerName
    Specifies the name of the computer from which the test should be initiated. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Test-NetworkPortRemote.ps1 -Destination "google.com" -Port 443

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [Parameter(Mandatory = $true)]
    [int]$Port,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Dest, $P)
            $result = Test-NetConnection -ComputerName $Dest -Port $P -ErrorAction SilentlyContinue
            return $result
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Destination, $Port)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $testResult = Invoke-Command @invokeParams
        }
        else {
            $testResult = &$scriptBlock -Dest $Destination -P $Port
        }

        $output = [PSCustomObject]@{
            SourceComputer = $ComputerName
            Destination    = $Destination
            Port           = $Port
            TcpTestSucceeded = $testResult.TcpTestSucceeded
            PingSucceeded  = $testResult.PingSucceeded
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
