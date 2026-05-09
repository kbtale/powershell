#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new virtual machine template
.DESCRIPTION
    Creates a template from an existing VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TemplateName
    Name of the new template
.PARAMETER VMId
    ID of the source virtual machine
.PARAMETER VMName
    Name of the source virtual machine
.PARAMETER Datacenter
    Datacenter where to place the new template
.EXAMPLE
    PS> ./New-Template.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -TemplateName "Win10Template" -VMName "Win10Source" -Datacenter "DC01"
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Datacenter
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "byID") { $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop }
        else { $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop }
        $center = Get-Datacenter -Name $Datacenter -Server $vmServer -ErrorAction Stop
        $result = New-Template -Name $TemplateName -VM $machine -Location $center -Server $vmServer -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}