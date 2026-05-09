#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Creates a new host
.DESCRIPTION
    Adds a new host to the inventory in a specified location.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Name
    Name for the new host
.PARAMETER LocationName
    Datacenter or folder name where to place the host
.PARAMETER Port
    Port on the host for the connection
.PARAMETER HostCredential
    PSCredential object for authenticating with the host
.EXAMPLE
    PS> ./New-Host.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "esxi01" -LocationName "Datacenter01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [int32]$Port,
    [pscredential]$HostCredential
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'PowerState', 'ConnectionState', 'IsStandalone', 'LicenseKey')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $location = Get-Folder -Server $vmServer -Name $LocationName -ErrorAction Stop
        if ($null -eq $location) {
            throw "Location $LocationName not found"
        }
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Name = $Name; Location = $location; Force = $null; Confirm = $false }
        if ($null -ne $HostCredential) { $cmdArgs.Add('Credential', $HostCredential) }
        if ($Port -gt 0) { $cmdArgs.Add('Port', $Port) }
        $null = Add-VMHost @cmdArgs
        $result = Get-VMHost -Server $vmServer -Name $Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
