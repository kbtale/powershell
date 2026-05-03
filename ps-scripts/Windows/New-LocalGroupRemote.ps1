#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Creates a new local security group on a computer

.DESCRIPTION
    Creates a new local security group on a local or remote machine.

.PARAMETER Name
    Specifies the name of the new local group.

.PARAMETER Description
    Specifies a description for the new group.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./New-LocalGroupRemote.ps1 -Name "AppUsers" -Description "Users for Application X"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Description,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($GroupName, $GroupDesc)
            $params = @{
                'Name' = $GroupName
                'Confirm' = $false
                'ErrorAction' = 'Stop'
            }
            if ($GroupDesc) { $params.Add('Description', $GroupDesc) }
            
            New-LocalGroup @params
            Get-LocalGroup -Name $GroupName | Select-Object Name, SID, Description
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $Description)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -GroupName $Name -GroupDesc $Description
        }

        $output = [PSCustomObject]@{
            Name         = $result.Name
            SID          = $result.SID.Value
            Description  = $result.Description
            ComputerName = $ComputerName
            Action       = "GroupCreated"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
