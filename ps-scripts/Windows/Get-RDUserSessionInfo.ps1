#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves active Remote Desktop user sessions

.DESCRIPTION
    Lists all active and disconnected user sessions on a local or remote machine. Provides details such as session name, username, ID, and state.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-RDUserSessionInfo.ps1 -ComputerName "SRV01"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            $sessions = qwinsta | Select-Object -Skip 1
            $results = foreach ($line in $sessions) {
                $trimmed = $line.Trim()
                if (-not $trimmed) { continue }
                
                # Handling fixed-width output of qwinsta
                $sessionName = $line.Substring(0, 18).Trim()
                $userName    = $line.Substring(19, 19).Trim()
                $id          = $line.Substring(39, 9).Trim()
                $state       = $line.Substring(48, 8).Trim()
                $type        = $line.Substring(57, 10).Trim()
                $device      = $line.Substring(67).Trim()
                
                if ($userName) {
                    [PSCustomObject]@{
                        SessionName = $sessionName
                        UserName    = $userName
                        SessionId   = $id
                        State       = $state
                        Type        = $type
                        Device      = $device
                    }
                }
            }
            $results
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $rawResult = Invoke-Command @invokeParams
        }
        else {
            $rawResult = &$scriptBlock
        }

        $output = foreach ($res in $rawResult) {
            [PSCustomObject]@{
                SessionName  = $res.SessionName
                UserName     = $res.UserName
                SessionId    = $res.SessionId
                State        = $res.State
                ComputerName = $ComputerName
            }
        }

        Write-Output ($output | Sort-Object UserName)
    }
    catch {
        throw
    }
}
