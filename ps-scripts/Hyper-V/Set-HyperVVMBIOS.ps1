#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures BIOS settings for Gen 1 virtual machines

.DESCRIPTION
    Updates BIOS configuration for Microsoft Hyper-V Generation 1 virtual machines, including startup order and NumLock status.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER StartupOrder
    Optional. Specifies the boot order of devices (CD, IDE, LegacyNetworkAdapter, Floppy).

.PARAMETER NumLock
    Optional. Specifies whether NumLock is enabled ($true) or disabled ($false).

.EXAMPLE
    PS> ./Set-HyperVVMBIOS.ps1 -Name "LegacyApp" -StartupOrder IDE, CD -NumLock $true

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('CD', 'IDE', 'LegacyNetworkAdapter', 'Floppy')]
    [string[]]$StartupOrder,

    [bool]$NumLock
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

        if ($vm.Generation -ne 1) {
            throw "Virtual machine '$Name' is Generation $($vm.Generation). BIOS settings only apply to Generation 1. Use Set-HyperVVMFirmware for Generation 2."
        }

        $biosParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        if ($PSBoundParameters.ContainsKey('NumLock')) {
            if ($NumLock) { $biosParams.Add('EnableNumLock', $true) }
            else { $biosParams.Add('DisableNumLock', $true) }
        }
        if ($StartupOrder) { $biosParams.Add('StartupOrder', $StartupOrder) }

        if ($biosParams.Count -gt 2) {
            Set-VMBios @biosParams
        }

        $result = [PSCustomObject]@{
            VMName       = $vm.Name
            Generation   = $vm.Generation
            StartupOrder = (Get-VMBios -VM $vm).StartupOrder
            NumLock      = (Get-VMBios -VM $vm).NumLockEnabled
            Action       = "BiosConfigUpdated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
