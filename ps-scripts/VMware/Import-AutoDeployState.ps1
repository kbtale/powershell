#Requires -Version 5.1
#Requires -Modules VMware.DeployAutomation

<#
    .SYNOPSIS
        VMware: Restores the state of the Auto Deploy service

    .DESCRIPTION
        Connects to a vSphere server and imports a previously exported Auto Deploy service state.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ImportFilePath
        File path of the restore file to import

    .EXAMPLE
        Import-AutoDeployState -VIServer "vcenter.contoso.com" -VICredential $cred -ImportFilePath "C:\Backup\state.zip"

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ImportFilePath
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = Import-AutoDeployState -Server $vmServer -ImportFilePath $ImportFilePath -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Result    = $result
        }
        Write-Output $output
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $vmServer) {
            Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}
