#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves video settings for a virtual machine

.DESCRIPTION
    Gets the video adapter configuration for a specified Microsoft Hyper-V virtual machine, including resolution and monitor settings.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMVideoInfo.ps1 -Name "GraphicSrv"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vm = Get-VM @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vm) {
            throw "Virtual machine '$Name' not found on '$ComputerName'."
        }

        $video = Get-VMVideo -VM $vm -ErrorAction Stop

        $results = foreach ($v in $video) {
            [PSCustomObject]@{
                VMName               = $vm.Name
                HorizontalResolution = $v.HorizontalResolution
                VerticalResolution   = $v.VerticalResolution
                Resolution           = "$($v.HorizontalResolution)x$($v.VerticalResolution)"
                Action               = "VideoAuditComplete"
                Status               = "Success"
                Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
