#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Adds members to a local group on a computer

.DESCRIPTION
    Adds one or more users or groups to a local security group on a local or remote machine. Supports adding members by name or SID.

.PARAMETER GroupName
    Specifies the name of the local group.

.PARAMETER Member
    Specifies one or more members to add. Can be local users, domain users, or domain groups (e.g., "Domain\User", "User01").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Add-LocalGroupMemberRemote.ps1 -GroupName "Administrators" -Member "CONTOSO\Domain Admins"

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
            Param($Group, $NewMembers)
            Add-LocalGroupMember -Group $Group -Member $NewMembers -Confirm:$false -ErrorAction Stop
            Get-LocalGroupMember -Group $Group | Select-Object Name, SID, PrincipalSource
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
            $result = &$scriptBlock -Group $GroupName -NewMembers $Member
        }

        $output = foreach ($m in $result) {
            [PSCustomObject]@{
                GroupName      = $GroupName
                MemberName     = $m.Name
                SID            = $m.SID.Value
                PrincipalSource = $m.PrincipalSource
                ComputerName   = $ComputerName
                Action         = "MemberAdded"
                Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $output
    }
    catch {
        throw
    }
}
