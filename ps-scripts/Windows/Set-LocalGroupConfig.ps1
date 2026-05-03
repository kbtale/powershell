#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Modifies a local security group configuration

.DESCRIPTION
    Updates properties of an existing local security group on a local or remote machine. Supports modifying the group's description and renaming the group.

.PARAMETER Name
    Specifies the name of the local group to modify.

.PARAMETER NewName
    Specifies a new name for the local group.

.PARAMETER Description
    Specifies a new description for the local group.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-LocalGroupConfig.ps1 -Name "TestGroup" -NewName "ProdGroup"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$NewName,

    [string]$Description,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($GroupName, $UpdatedName, $GroupDesc, $BoundParams)
            $targetName = $GroupName
            if ($BoundParams.ContainsKey('Description')) {
                Set-LocalGroup -Name $GroupName -Description $GroupDesc -ErrorAction Stop
            }
            if ($BoundParams.ContainsKey('NewName')) {
                Rename-LocalGroup -Name $GroupName -NewName $UpdatedName -ErrorAction Stop
                $targetName = $UpdatedName
            }
            
            Get-LocalGroup -Name $targetName | Select-Object Name, SID, Description
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($Name, $NewName, $Description, $PSBoundParameters)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -GroupName $Name -UpdatedName $NewName -GroupDesc $Description -BoundParams $PSBoundParameters
        }

        $output = [PSCustomObject]@{
            Name         = $result.Name
            SID          = $result.SID.Value
            Description  = $result.Description
            ComputerName = $ComputerName
            Action       = "GroupModified"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
