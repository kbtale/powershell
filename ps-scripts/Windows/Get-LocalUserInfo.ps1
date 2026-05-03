#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves information about local user accounts

.DESCRIPTION
    Gets details of local user accounts on a local or remote computer. Supports filtering by name or SID.

.PARAMETER Name
    Specifies the name of the local user to retrieve. Supports wildcards. Defaults to all users.

.PARAMETER SID
    Specifies the security ID (SID) of the local user to retrieve.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-LocalUserInfo.ps1 -Name "Admin*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(ParameterSetName = 'ByName')]
    [string]$Name = "*",

    [Parameter(Mandatory = $true, ParameterSetName = 'BySID')]
    [string]$SID,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($UserName, $UserSID, $SetName)
            if ($SetName -eq 'BySID') {
                Get-LocalUser -SID $UserSID -ErrorAction Stop | Select-Object Name, SID, Enabled, LastLogon, Description
            }
            else {
                Get-LocalUser -Name $UserName -ErrorAction Stop | Select-Object Name, SID, Enabled, LastLogon, Description
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $SID, $PSCmdlet.ParameterSetName)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -UserName $Name -UserSID $SID -SetName $PSCmdlet.ParameterSetName
        }

        $output = foreach ($u in $result) {
            [PSCustomObject]@{
                Name         = $u.Name
                SID          = $u.SID.Value
                Enabled      = $u.Enabled
                LastLogon    = $u.LastLogon
                Description  = $u.Description
                ComputerName = $ComputerName
            }
        }

        Write-Output ($output | Sort-Object Name)
    }
    catch {
        throw
    }
}
