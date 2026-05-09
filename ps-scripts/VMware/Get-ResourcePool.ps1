#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves available resource pools
.DESCRIPTION
    Retrieves resource pools by ID, name, or virtual machine membership.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the resource pool
.PARAMETER Name
    Name of the resource pool; retrieves all if empty
.PARAMETER VM
    Virtual machine whose resource pool to retrieve
.PARAMETER NoRecursion
    Disable recursive behavior
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-ResourcePool.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [ValidateSet('*', 'Name', 'Id', 'MemReservationGB', 'MemLimitGB', 'CpuLimitMHz', 'CpuReservationMHz')]
    [string[]]$Properties = @('Name', 'Id', 'MemReservationGB', 'MemLimitGB', 'CpuLimitMHz', 'CpuReservationMHz')
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; NoRecursion = $NoRecursion }
        if ($PSCmdlet.ParameterSetName -eq "byID") { $cmdArgs.Add('ID', $ID) }
        elseif ($PSCmdlet.ParameterSetName -eq "byVM") { $cmdArgs.Add('VM', $VM) }
        elseif (-not [System.String]::IsNullOrWhiteSpace($Name)) { $cmdArgs.Add('Name', $Name) }
        $result = Get-ResourcePool @cmdArgs | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}