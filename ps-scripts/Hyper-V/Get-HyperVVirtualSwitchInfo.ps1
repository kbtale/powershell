#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves properties of a specific virtual switch

.DESCRIPTION
    Gets detailed configuration properties for a specified Microsoft Hyper-V virtual switch, including its type, management OS accessibility, and network adapter bindings.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual switch to retrieve.

.EXAMPLE
    PS> ./Get-HyperVVirtualSwitchInfo.ps1 -Name "vSwitch-External"

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

        $vSwitch = Get-VMSwitch @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vSwitch) {
            throw "Virtual switch '$Name' not found on '$ComputerName'."
        }

        $results = foreach ($s in $vSwitch) {
            [PSCustomObject]@{
                Name               = $s.Name
                ID                 = $s.Id
                SwitchType         = $s.SwitchType
                AllowManagementOS  = $s.AllowManagementOS
                NetAdapterInterfaceDescription = if ($s.NetAdapterInterfaceDescription) { $s.NetAdapterInterfaceDescription } else { "N/A" }
                Notes              = $s.Notes
                IsDeleted          = $s.IsDeleted
                ComputerName       = $s.ComputerName
                LastModified       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
