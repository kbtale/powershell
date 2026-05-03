#Requires -Version 5.1
#Requires -Modules Microsoft.PowerShell.LocalAccounts

<#
.SYNOPSIS
    Windows: Lists members of a specified local security group

.DESCRIPTION
    Retrieves a list of users and groups that are members of a specified local group on a local or remote computer. This script provides the member name, principal source (Local/AD), and SID for security auditing.

.PARAMETER Name
    Specifies the name of the local group to query (e.g., "Administrators").

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-LocalGroupMemberInfo.ps1 -Name "Administrators"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Name,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process
{
    try
    {
        $scriptBlock = {
            Param($GroupName)
            Get-LocalGroupMember -Group $GroupName -ErrorAction Stop | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_.Name
                    PrincipalSource = $_.PrincipalSource
                    ObjectClass  = $_.ObjectClass
                    SID          = $_.SID.Value
                    ComputerName = $env:COMPUTERNAME
                }
            }
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $Name
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
            $result = &$scriptBlock -GroupName $Name
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}
