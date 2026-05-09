#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new virtual machine from a template
.DESCRIPTION
    Creates a new VM from a template on a datastore or cluster.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateName
    Virtual machine template to use
.PARAMETER HostName
    Host on which to create the new VM
.PARAMETER VMName
    Name for the new virtual machine
.PARAMETER DatastoreName
    Datastore where to place the new VM
.PARAMETER ClusterName
    Datastore cluster where to place the new VM
.PARAMETER Notes
    Description of the new VM
.PARAMETER DiskStorageFormat
    Storage format of the disks
.PARAMETER OSCustomizationSpec
    Customization specification to apply
.PARAMETER Location
    Folder where to place the new VM
.PARAMETER DrsAutomationLevel
    DRS automation level
.PARAMETER HAIsolationResponse
    HA isolation response
.PARAMETER HARestartPriority
    HA restart priority
.EXAMPLE
    PS> ./New-VirtualMachineFromTemplate.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TemplateName "WinTmpl" -HostName "esxi01" -VMName "NewVM" -DatastoreName "ds1"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "onDatastore")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$HostName,
    [Parameter(Mandatory = $true, ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "onDatastore")]
    [string]$DatastoreName,
    [Parameter(Mandatory = $true, ParameterSetName = "onCluster")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$Notes,
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick",
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$OSCustomizationSpec,
    [Parameter(ParameterSetName = "onDatastore")]
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
        if ($PSCmdlet.ParameterSetName -eq "onDatastore") {
            $store = Get-Datastore -Server $vmServer -Name $DatastoreName -ErrorAction Stop
        }
        else {
            $store = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop
        }
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $template = Get-Template -Server $vmServer -Name $TemplateName -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $VMName; VMHost = $vmHost; Notes = $Notes; Confirm = $false; Template = $template; DiskStorageFormat = $DiskStorageFormat; Datastore = $store }
        if (-not [System.String]::IsNullOrEmpty($Location)) {
            $folder = Get-Folder -Server $vmServer -Name $Location -ErrorAction Stop
            $cmdArgs.Add('Location', $folder)
        }
        if ($PSBoundParameters.ContainsKey('OSCustomizationSpec')) {
            $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $vmServer
            $cmdArgs.Add('OSCustomizationSpec', $spec)
        }
        $machine = New-VM @cmdArgs | Select-Object $Properties
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
