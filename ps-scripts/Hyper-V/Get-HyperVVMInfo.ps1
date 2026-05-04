#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves properties of a specific virtual machine

.DESCRIPTION
    Gets detailed configuration, status, and resource usage properties for a specified Microsoft Hyper-V virtual machine.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMInfo.ps1 -Name "Linux-Web-01"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vm = Get-VM @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vm) {
            throw "Virtual machine '$Name' not found on '$ComputerName'."
        }

        $results = foreach ($v in $vm) {
            [PSCustomObject]@{
                Name             = $v.Name
                Id               = $v.Id
                State            = $v.State
                Status           = $v.Status
                Uptime           = $v.Uptime
                MemoryAssigned   = $v.MemoryAssigned
                CPUUsage         = $v.CPUUsage
                Version          = $v.Version
                Generation       = $v.Generation
                Path             = $v.Path
                ComputerName     = $v.ComputerName
                LastModified     = $v.WhenChanged
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
