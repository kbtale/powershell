#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits all virtual switches on a Hyper-V host

.DESCRIPTION
    Retrieves a list of all virtual switches on a Microsoft Hyper-V host, including switch types and operational metadata.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER SwitchType
    Optional. Filters virtual switches by type (External, Internal, Private).

.EXAMPLE
    PS> ./Get-HyperVVirtualSwitchInventory.ps1 -SwitchType External

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [ValidateSet('All', 'External', 'Internal', 'Private')]
    [string]$SwitchType = "All"
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vSwitches = Get-VMSwitch @params

        if ($SwitchType -ne "All") {
            $vSwitches = $vSwitches | Where-Object { $_.SwitchType -eq $SwitchType }
        }

        $results = foreach ($sw in $vSwitches) {
            [PSCustomObject]@{
                Name               = $sw.Name
                SwitchType         = $sw.SwitchType
                AllowManagementOS  = $sw.AllowManagementOS
                IovEnabled         = $sw.IovEnabled
                NetAdapterDescription = $sw.NetAdapterInterfaceDescription
                ComputerName       = $sw.ComputerName
                Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
