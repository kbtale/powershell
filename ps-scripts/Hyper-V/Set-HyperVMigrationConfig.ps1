#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures Live Migration settings on a Hyper-V host

.DESCRIPTION
    Enables, disables, and configures Microsoft Hyper-V Live Migration settings, including authentication, performance options, and allowed networks.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Enabled
    Specifies whether Live Migration is enabled ($true) or disabled ($false).

.PARAMETER MaxMigrations
    Optional. Specifies the maximum number of simultaneous live migrations.

.PARAMETER AuthenticationType
    Optional. Specifies the authentication protocol (CredSSP or Kerberos).

.PARAMETER PerformanceOption
    Optional. Specifies the performance option (TCPIP, Compression, or SMB).

.PARAMETER UseAnyNetwork
    Optional. If set to $true, any available network can be used for migration.

.PARAMETER AddNetworks
    Optional. Specifies an array of subnets (e.g., "192.168.1.0/24") to add to the migration network list.

.PARAMETER RemoveNetworks
    Optional. Specifies an array of subnets to remove from the migration network list.

.EXAMPLE
    PS> ./Set-HyperVMigrationConfig.ps1 -Enabled $true -AuthenticationType Kerberos -MaxMigrations 4

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [int]$MaxMigrations,

    [ValidateSet('CredSSP', 'Kerberos')]
    [string]$AuthenticationType,

    [ValidateSet('TCPIP', 'Compression', 'SMB')]
    [string]$PerformanceOption,

    [bool]$UseAnyNetwork,

    [string[]]$AddNetworks,

    [string[]]$RemoveNetworks
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        if ($Enabled) {
            Enable-VMMigration @params
        }
        else {
            Disable-VMMigration @params
        }

        $hostParams = @{
            'ComputerName' = $ComputerName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $hostParams.Add('Credential', $Credential) }

        if ($PSBoundParameters.ContainsKey('MaxMigrations')) { $hostParams.Add('MaximumVirtualMachineMigrations', $MaxMigrations) }
        if ($PSBoundParameters.ContainsKey('AuthenticationType')) { $hostParams.Add('VirtualMachineMigrationAuthenticationType', $AuthenticationType) }
        if ($PSBoundParameters.ContainsKey('PerformanceOption')) { $hostParams.Add('VirtualMachineMigrationPerformanceOption', $PerformanceOption) }
        if ($PSBoundParameters.ContainsKey('UseAnyNetwork')) { $hostParams.Add('UseAnyNetworkForMigration', $UseAnyNetwork) }

        if ($hostParams.Count -gt 3) {
            Set-VMHost @hostParams
        }

        foreach ($net in $AddNetworks) {
            Add-VMMigrationNetwork @params -Subnet $net.Trim()
        }
        foreach ($net in $RemoveNetworks) {
            Remove-VMMigrationNetwork @params -Subnet $net.Trim()
        }

        $hostInfo = Get-VMHost -ComputerName $ComputerName -ErrorAction Stop
        $result = [PSCustomObject]@{
            ComputerName       = $hostInfo.Name
            MigrationEnabled   = $hostInfo.VirtualMachineMigrationEnabled
            MaxMigrations      = $hostInfo.MaximumVirtualMachineMigrations
            AuthenticationType = $hostInfo.VirtualMachineMigrationAuthenticationType
            PerformanceOption  = $hostInfo.VirtualMachineMigrationPerformanceOption
            Action             = "MigrationConfigUpdated"
            Status             = "Success"
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
