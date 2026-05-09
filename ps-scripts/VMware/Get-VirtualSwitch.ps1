#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves virtual switches
.DESCRIPTION
    Retrieves virtual switches by ID, name, datacenter, or VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the virtual switch
.PARAMETER Name
    Name of the virtual switch; retrieves all if empty
.PARAMETER Datacenter
    Filters switches connected to hosts in the specified datacenter
.PARAMETER VM
    Virtual machine whose switch to retrieve
.PARAMETER Standard
    Retrieve only standard VirtualSwitch objects
.EXAMPLE
    PS> ./Get-VirtualSwitch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatacenter")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byDatacenter")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byDatacenter")]
    [string]$Datacenter,
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatacenter")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$Standard
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Standard = $Standard }
        if ($PSCmdlet.ParameterSetName -eq "byID") { $cmdArgs.Add('ID', $ID) }
        elseif ($PSCmdlet.ParameterSetName -eq "byName") { if (-not [System.String]::IsNullOrWhiteSpace($Name)) { $cmdArgs.Add('Name', $Name) } }
        elseif ($PSCmdlet.ParameterSetName -eq "byDatacenter") { $cmdArgs.Add('Datacenter', $Datacenter) }
        elseif ($PSCmdlet.ParameterSetName -eq "byVM") { $cmdArgs.Add('VM', $VM) }
        $result = Get-VirtualSwitch @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}