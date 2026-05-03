#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Removes members from a local group on a computer

.DESCRIPTION
    Removes one or more users or groups from a local security group on a local or remote machine.

.PARAMETER GroupName
    Specifies the name of the local group.

.PARAMETER Member
    Specifies one or more members to remove (e.g., "Domain\User", "User01").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Remove-LocalGroupMemberRemote.ps1 -GroupName "Remote Desktop Users" -Member "User02"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string[]]$Member,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Group, $OldMembers)
            Remove-LocalGroupMember -Group $Group -Member $OldMembers -Confirm:$false -ErrorAction Stop
            Get-LocalGroupMember -Group $Group | Select-Object Name, SID
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($GroupName, $Member)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Group $GroupName -OldMembers $Member
        }

        $output = [PSCustomObject]@{
            GroupName      = $GroupName
            RemovedMembers = $Member -join ", "
            RemainingCount = if ($result) { $result.Count } else { 0 }
            ComputerName   = $ComputerName
            Action         = "MembersRemoved"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
