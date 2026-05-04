#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures virtual machine video settings

.DESCRIPTION
    Updates the video resolution and resolution type for a Microsoft Hyper-V virtual machine display adapter.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER ResolutionType
    Specifies the resolution type (Default, Maximum, Single).

.PARAMETER HorizontalResolution
    Specifies the horizontal resolution in pixels.

.PARAMETER VerticalResolution
    Specifies the vertical resolution in pixels.

.EXAMPLE
    PS> ./Set-HyperVVMVideo.ps1 -Name "GraphicVM" -ResolutionType Single -HorizontalResolution 1920 -VerticalResolution 1080

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Default', 'Maximum', 'Single')]
    [string]$ResolutionType,

    [Parameter(Mandatory = $true)]
    [uint16]$HorizontalResolution,

    [Parameter(Mandatory = $true)]
    [uint16]$VerticalResolution
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

        Set-VMVideo -VM $vm -ResolutionType $ResolutionType -HorizontalResolution $HorizontalResolution -VerticalResolution $VerticalResolution -ErrorAction Stop

        $updatedVideo = Get-VMVideo -VM $vm
        
        $result = [PSCustomObject]@{
            VMName               = $vm.Name
            ResolutionType       = $updatedVideo.ResolutionType
            HorizontalResolution = $updatedVideo.HorizontalResolution
            VerticalResolution   = $updatedVideo.VerticalResolution
            Action               = "VideoSettingsUpdated"
            Status               = "Success"
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
