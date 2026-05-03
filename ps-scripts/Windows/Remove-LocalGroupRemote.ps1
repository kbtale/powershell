#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Removes a local security group from a computer

.DESCRIPTION
    Deletes a local security group on a local or remote machine.

.PARAMETER Name
    Specifies the name of the local group to remove.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-LocalGroupRemote.ps1 -Name "TestGroup"

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
            Param($GroupName)
            Remove-LocalGroup -Name $GroupName -Confirm:$false -ErrorAction Stop
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
            &$scriptBlock -GroupName $Name
        }

        $output = [PSCustomObject]@{
            Name         = $Name
            ComputerName = $ComputerName
            Action       = "GroupRemoved"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
