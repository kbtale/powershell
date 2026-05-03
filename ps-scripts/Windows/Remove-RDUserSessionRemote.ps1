#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Logoff a Remote Desktop user session

.DESCRIPTION
    Terminates a specific user session on a local or remote machine using its Session ID.

.PARAMETER SessionId
    Specifies the ID of the user session to terminate.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-RDUserSessionRemote.ps1 -SessionId 2

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [int]$SessionId,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Id)
            rwinsta $Id
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $SessionId
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -Id $SessionId
        }

        $result = [PSCustomObject]@{
            SessionId    = $SessionId
            ComputerName = $ComputerName
            Action       = "SessionTerminated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
