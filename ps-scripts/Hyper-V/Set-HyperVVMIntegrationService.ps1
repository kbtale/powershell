#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures virtual machine integration services

.DESCRIPTION
    Enables or disables specific Microsoft Hyper-V integration services for a virtual machine, such as Guest Services, Time Synchronization, and Shutdown.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Service
    Specifies the integration service(s) to configure.

.PARAMETER Enabled
    Specifies whether the specified service(s) should be enabled ($true) or disabled ($false).

.EXAMPLE
    PS> ./Set-HyperVVMIntegrationService.ps1 -Name "Linux-Web" -Service "Guest Service Interface" -Enabled $true

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Guest Service Interface', 'Heartbeat', 'Key-Value Pair Exchange', 'Shutdown', 'Time Synchronization', 'VSS')]
    [string[]]$Service,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled
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

        foreach ($svc in $Service) {
            if ($Enabled) {
                Enable-VMIntegrationService -VM $vm -Name $svc -ErrorAction Stop
            }
            else {
                Disable-VMIntegrationService -VM $vm -Name $svc -ErrorAction Stop
            }
        }

        $results = Get-VMIntegrationService -VM $vm | Where-Object { $Service -contains $_.Name } | Select-Object Name, Enabled
        
        $result = [PSCustomObject]@{
            VMName    = $vm.Name
            Services  = $results
            Action    = "IntegrationServicesUpdated"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
