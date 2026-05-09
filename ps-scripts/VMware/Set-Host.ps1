#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Modifies the configuration of the host
.DESCRIPTION
    Modifies host state, license key, and time zone settings.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER ID
    ID of the host to modify
.PARAMETER Name
    Name of the host to modify
.PARAMETER State
    State of the host (Connected, Disconnected, Maintenance)
.PARAMETER Evacuate
    Automatically reregister compatible VMs
.PARAMETER LicenseKey
    License key for the host
.PARAMETER TimeZoneName
    Time zone name for the host
.EXAMPLE
    PS> ./Set-Host.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Name "esxi01" -State "Maintenance"
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
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Connected", "Disconnected", "Maintenance")]
    [string]$State,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$Evacuate,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$LicenseKey,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$TimeZoneName
)
Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'PowerState', 'ConnectionState', 'IsStandalone', 'LicenseKey')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmdArgs = @{ ErrorAction = 'Stop'; Server = $vmServer; Confirm = $false }
        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $vmHost = Get-VMHost @cmdArgs -ID $ID
        }
        else {
            $vmHost = Get-VMHost @cmdArgs -Name $Name
        }
        $cmdArgs.Add('VMHost', $vmHost)
        if ($PSBoundParameters.ContainsKey('State')) { $null = Set-VMHost @cmdArgs -State $State }
        if ($PSBoundParameters.ContainsKey('LicenseKey')) { $null = Set-VMHost @cmdArgs -LicenseKey $LicenseKey }
        if ($PSBoundParameters.ContainsKey('TimeZoneName')) {
            $timezone = Get-VMHostAvailableTimeZone -Server $vmServer -Name $TimeZoneName -ErrorAction Stop
            $null = Set-VMHost @cmdArgs -TimeZone $timezone
        }
        if ($PSBoundParameters.ContainsKey('Evacuate')) { $null = Set-VMHost @cmdArgs -Evacuate:$Evacuate }
        $result = Get-VMHost -Server $vmServer -Name $vmHost.Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
