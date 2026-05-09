#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves virtual machines on a vCenter Server system
.DESCRIPTION
    Retrieves VMs by ID, name, or datastore.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMId
    ID of the virtual machine
.PARAMETER VMName
    Name of the virtual machine; retrieves all if empty
.PARAMETER Datastore
    Datastore to filter VMs by
.PARAMETER NoRecursion
    Disable recursive behavior
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-VirtualMachine.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [string]$Datastore,
    [Parameter(ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [ValidateSet('*', 'Name', 'Id', 'PowerState', 'NumCpu', 'Notes', 'Guest', 'GuestId', 'MemoryMB', 'UsedSpaceGB', 'ProvisionedSpaceGB', 'Folder')]
    [string[]]$Properties = @('Name', 'Id', 'PowerState', 'NumCpu', 'Notes', 'Guest', 'GuestId', 'MemoryMB', 'UsedSpaceGB', 'ProvisionedSpaceGB', 'Folder')
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; NoRecursion = $NoRecursion }
        if ($PSCmdlet.ParameterSetName -eq "byID") { $cmdArgs.Add('Id', $VMId) }
        elseif ($PSCmdlet.ParameterSetName -eq "byName") { $cmdArgs.Add('Name', $VMName) }
        elseif ($PSCmdlet.ParameterSetName -eq "byDatastore") { $cmdArgs.Add('Datastore', $Datastore) }
        $result = Get-VM @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}