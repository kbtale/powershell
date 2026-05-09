#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the hosts on a vCenter Server system
.DESCRIPTION
    Connects to a vCenter Server and retrieves hosts by ID, name, datastore, resource pool, or VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the host to retrieve
.PARAMETER Name
    Name of the host to retrieve; if empty, all hosts are retrieved
.PARAMETER Datastore
    Datastore or datastore cluster to filter hosts by
.PARAMETER VM
    Virtual machine whose host you want to retrieve
.PARAMETER NoRecursion
    Disables recursive behavior
.PARAMETER Properties
    List of properties to expand; use * for all properties
.EXAMPLE
    PS> ./Get-Host.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.EXAMPLE
    PS> ./Get-Host.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "esxi01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "byResourcePool")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [Parameter(Mandatory = $true, ParameterSetName = "byResourcePool")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byDatastore")]
    [string]$Datastore,
    [Parameter(Mandatory = $true, ParameterSetName = "byResourcePool")]
    [string]$ResourcePool,
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [Parameter(ParameterSetName = "byResourcePool")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [Parameter(ParameterSetName = "byResourcePool")]
    [Parameter(ParameterSetName = "byVM")]
    [ValidateSet('*', 'Name', 'Id', 'PowerState', 'ConnectionState', 'IsStandalone', 'LicenseKey')]
    [string[]]$Properties = @('Name', 'Id', 'PowerState', 'ConnectionState', 'IsStandalone', 'LicenseKey')
)
Process {
    $vmServer = $null
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; NoRecursion = $NoRecursion }
        if ($PSCmdlet.ParameterSetName -eq "byID") { $cmdArgs.Add('ID', $ID) }
        elseif ($PSCmdlet.ParameterSetName -eq "byDatastore") { $cmdArgs.Add('Datastore', $Datastore) }
        elseif ($PSCmdlet.ParameterSetName -eq "byVM") { $cmdArgs.Add('VM', $VM) }
        else {
            if (-not [System.String]::IsNullOrWhiteSpace($Name)) { $cmdArgs.Add('Name', $Name) }
        }
        $result = Get-VMHost @cmdArgs -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
