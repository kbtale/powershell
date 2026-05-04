#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Lists all virtual switches on a Hyper-V host

.DESCRIPTION
    Retrieves an inventory of all virtual switches on a specified Hyper-V host. Supports filtering by switch type (External, Internal, Private).

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER SwitchType
    Optional. Specifies the type of virtual switches to retrieve (External, Internal, Private).

.EXAMPLE
    PS> ./Get-HyperVVirtualSwitch.ps1 -SwitchType External

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [ValidateSet('External', 'Internal', 'Private')]
    [string]$SwitchType
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        if ($SwitchType) { $params.Add('SwitchType', $SwitchType) }

        $switches = Get-VMSwitch @params
        
        $results = foreach ($s in $switches) {
            [PSCustomObject]@{
                Name               = $s.Name
                SwitchType         = $s.SwitchType
                AllowManagementOS  = $s.AllowManagementOS
                InterfaceDescription = $s.NetAdapterInterfaceDescription
                ComputerName       = $s.ComputerName
                Status             = "Available" # Basic status indicator
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
