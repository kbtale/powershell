#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves information about local security groups

.DESCRIPTION
    Gets details of local security groups on a local or remote computer. Supports filtering by group name or SID.

.PARAMETER Name
    Specifies the name of the local group to retrieve. Supports wildcards. Defaults to all groups.

.PARAMETER SID
    Specifies the security ID (SID) of the local group to retrieve.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-LocalGroupInfo.ps1 -Name "Admin*"

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
            Param($GroupName, $GroupSID, $SetName)
            if ($SetName -eq 'BySID') {
                Get-LocalGroup -SID $GroupSID -ErrorAction Stop | Select-Object Name, SID, Description
            }
            else {
                Get-LocalGroup -Name $GroupName -ErrorAction Stop | Select-Object Name, SID, Description
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
            $result = &$scriptBlock -GroupName $Name -GroupSID $SID -SetName $PSCmdlet.ParameterSetName
        }

        $output = foreach ($g in $result) {
            [PSCustomObject]@{
                Name         = $g.Name
                SID          = $g.SID.Value
                Description  = $g.Description
                ComputerName = $ComputerName
            }
        }

        Write-Output ($output | Sort-Object Name)
    }
    catch {
        throw
    }
}
