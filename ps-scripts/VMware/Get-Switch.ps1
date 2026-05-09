#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves vSphere distributed switches
.DESCRIPTION
    Retrieves vSphere distributed switches by name or ID on a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER SwitchName
    Name of the distributed switch to retrieve; retrieves all if empty
.PARAMETER SwitchID
    ID of the distributed switch to retrieve
.EXAMPLE
    PS> ./Get-Switch.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding(DefaultParameterSetName = "ByName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true, ParameterSetName = "ByID")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true, ParameterSetName = "ByID")]
    [pscredential]$VICredential,
    [Parameter(ParameterSetName = "ByName")]
    [string]$SwitchName,
    [Parameter(Mandatory = $true, ParameterSetName = "ByID")]
    [string]$SwitchID
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ($PSCmdlet.ParameterSetName -eq "ByID") { $result = Get-VDSwitch -Server $vmServer -Id $SwitchID -ErrorAction Stop | Select-Object * }
        elseif ([System.String]::IsNullOrWhiteSpace($SwitchName)) { $result = Get-VDSwitch -Server $vmServer -ErrorAction Stop | Select-Object * }
        else { $result = Get-VDSwitch -Server $vmServer -Name $SwitchName -ErrorAction Stop | Select-Object * }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}