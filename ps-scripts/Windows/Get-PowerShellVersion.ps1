#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves PowerShell and .NET framework versions

.DESCRIPTION
    Audits the version of PowerShell (Engine, Edition, Compatibility) and the installed .NET Framework on local or remote computers. This is essential for ensuring environment compatibility for scripts and modules.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-PowerShellVersion.ps1 -ComputerName "DC01"

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
            $dotNetVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version
            
            [PSCustomObject]@{
                ComputerName     = $env:COMPUTERNAME
                PSVersion        = $PSVersionTable.PSVersion.ToString()
                PSEdition        = $PSVersionTable.PSEdition
                OS               = $PSVersionTable.OS
                DotNetFramework  = $dotNetVersion
                SerializationVer = $PSVersionTable.SerializationVersion.ToString()
            }
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
