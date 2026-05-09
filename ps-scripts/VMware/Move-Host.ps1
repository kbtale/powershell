#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Moves the specified host to another location
.DESCRIPTION
    Moves a host to another folder destination.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the host to move
.PARAMETER Name
    Name of the host to move
.PARAMETER DestinationName
    Destination folder name where to move the host
.EXAMPLE
    PS> ./Move-Host.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "esxi01" -DestinationName "TargetFolder"
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
    [string]$ID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$DestinationName
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'PowerState', 'ConnectionState', 'IsStandalone', 'LicenseKey')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $vmHost = Get-VMHost -Server $vmServer -ID $ID -ErrorAction Stop
        }
        else {
            $vmHost = Get-VMHost -Server $vmServer -Name $Name -ErrorAction Stop
        }
        $destination = Get-Folder -Server $vmServer -Name $DestinationName -ErrorAction Stop
        if ($null -eq $destination) {
            throw "Destination $DestinationName not found"
        }
        $null = Move-VMHost -VMHost $vmHost -Destination $destination -Server $vmServer -Confirm:$false -ErrorAction Stop
        $result = Get-VMHost -Server $vmServer -Name $vmHost.Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
