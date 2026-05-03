#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Removes a local user account from a computer

.DESCRIPTION
    Deletes a local user account on a local or remote machine.

.PARAMETER Name
    Specifies the name of the local user to remove.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-LocalUserRemote.ps1 -Name "User02"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($UserName)
            Remove-LocalUser -Name $UserName -Confirm:$false -ErrorAction Stop
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $Name
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -UserName $Name
        }

        $output = [PSCustomObject]@{
            Name         = $Name
            ComputerName = $ComputerName
            Action       = "UserRemoved"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
