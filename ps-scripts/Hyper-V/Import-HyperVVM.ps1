#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Imports a virtual machine from a configuration file

.DESCRIPTION
    Imports a Microsoft Hyper-V virtual machine using a specifies configuration file (.vmcx or .xml). Supports in-place registration or copying files with new IDs.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Path
    Specifies the path to the virtual machine configuration file.

.PARAMETER Register
    If set, registers the virtual machine in-place using its existing ID and file locations.

.PARAMETER Copy
    If set, copies the virtual machine files to the host's default locations.

.PARAMETER GenerateNewId
    If set, generates a new unique identifier for the imported virtual machine.

.PARAMETER VhdDestinationPath
    Optional. Specifies the folder to which the VHD files should be copied.

.EXAMPLE
    PS> ./Import-HyperVVM.ps1 -Path "D:\Exports\WebSrv\Virtual Machines\GUID.vmcx" -Register

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(ParameterSetName = "Register")]
    [switch]$Register,

    [Parameter(ParameterSetName = "Copy")]
    [switch]$Copy,

    [Parameter(ParameterSetName = "Copy")]
    [switch]$GenerateNewId,

    [string]$VhdDestinationPath
)

Process {
    try {
        $params = @{
            'Path'         = $Path
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        if ($Register) {
            $params.Add('Register', $true)
        }
        else {
            if ($GenerateNewId) { $params.Add('GenerateNewId', $true) }
            if ($VhdDestinationPath) { $params.Add('VhdDestinationPath', $VhdDestinationPath) }
        }

        $vm = Import-VM @params

        $result = [PSCustomObject]@{
            Name         = $vm.Name
            Id           = $vm.Id
            Path         = $vm.Path
            Action       = "VirtualMachineImported"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
