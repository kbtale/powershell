#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves active user sessions and logged-on accounts

.DESCRIPTION
    Lists currently logged-on users and their session details on a local or remote computer. This script identifies interactive, service, and network logon sessions to provide a complete view of system access.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-LocalUserSession.ps1

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $scriptBlock = {
            $sessions = Get-CimInstance -ClassName Win32_LogonSession -ErrorAction Stop
            $results = foreach ($session in $sessions)
            {
                # LogonType 2 = Interactive, 10 = RemoteInteractive (RDP)
                if ($session.LogonType -in @(2, 10, 11))
                {
                    $userLink = Get-CimAssociatedInstance -InputObject $session -ResultClassName Win32_UserAccount -ErrorAction SilentlyContinue
                    
                    if ($userLink)
                    {
                        [PSCustomObject]@{
                            UserName     = "$($userLink.Domain)\$($userLink.Name)"
                            LogonType    = switch($session.LogonType) {
                                2  { "Interactive" }
                                10 { "RemoteInteractive (RDP)" }
                                11 { "CachedInteractive" }
                                default { "Other ($($session.LogonType))" }
                            }
                            StartTime    = $session.StartTime
                            LogonId      = $session.LogonId
                            ComputerName = $env:COMPUTERNAME
                        }
                    }
                }
            }
            $results
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential)
            {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else
        {
            $result = &$scriptBlock
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
