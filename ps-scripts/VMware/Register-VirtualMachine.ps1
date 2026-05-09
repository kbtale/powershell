#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Register a new virtual machine
.DESCRIPTION
    Registers an existing VM from a VMX file path.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host for the new VM
.PARAMETER VMName
    Name for the new virtual machine
.PARAMETER NameOfVM
    Name for the new VM (cluster parameter set)
.PARAMETER VMFilePath
    Path to the VM file to register
.PARAMETER ClusterName
    Datastore cluster where to place the VM
.PARAMETER Notes
    Description of the new VM
.PARAMETER Location
    Folder where to place the new VM
.PARAMETER DrsAutomationLevel
    DRS automation level
.PARAMETER HAIsolationResponse
    HA isolation response
.PARAMETER HARestartPriority
    HA restart priority
.EXAMPLE
    PS> ./Register-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -VMName "RegisteredVM" -VMFilePath "[ds] VM/VM.vmx"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "Default")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$NameOfVM,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$VMFilePath,
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$Notes,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$Location,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated", "AsSpecifiedByCluster", "Disabled")]
    [string]$DrsAutomationLevel,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("AsSpecifiedByCluster", "PowerOff", "DoNothing")]
    [string]$HAIsolationResponse,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("Disabled", "Low", "Medium", "High", "ClusterRestartPriority")]
    [string]$HARestartPriority
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'NumCpu', 'CoresPerSocket', 'Notes', 'GuestId', 'MemoryGB', 'VMSwapfilePolicy', 'ProvisionedSpaceGB', 'Folder')
        if ([System.String]::IsNullOrWhiteSpace($Notes)) { $Notes = " " }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $VMName; VMHost = $vmHost; Notes = $Notes; Confirm = $false; VMFilePath = $VMFilePath }
        if ($PSCmdlet.ParameterSetName -eq "onCluster") {
            $store = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop
            $cmdArgs['Name'] = $NameOfVM
            $cmdArgs.Add('ResourcePool', $store)
        }
        if (-not [System.String]::IsNullOrEmpty($Location)) {
            $folder = Get-Folder -Server $vmServer -Name $Location -ErrorAction Stop
            $cmdArgs.Add('Location', $folder)
        }
        $machine = New-VM @cmdArgs
        if ($PSCmdlet.ParameterSetName -eq "onCluster") {
            if ($PSBoundParameters.ContainsKey('DrsAutomationLevel')) { $null = Set-VM -Server $vmServer -VM $machine -DrsAutomationLevel $DrsAutomationLevel -Confirm:$False -ErrorAction Stop }
            if ($PSBoundParameters.ContainsKey('HAIsolationResponse')) { $null = Set-VM -Server $vmServer -VM $machine -HAIsolationResponse $HAIsolationResponse -Confirm:$False -ErrorAction Stop }
            if ($PSBoundParameters.ContainsKey('HARestartPriority')) { $null = Set-VM -Server $vmServer -VM $machine -HARestartPriority $HARestartPriority -Confirm:$False -ErrorAction Stop }
        }
        $result = Get-VM -Server $vmServer -Name $VMName | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
