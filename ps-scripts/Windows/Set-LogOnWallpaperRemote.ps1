#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Configures the Windows Lock Screen image

.DESCRIPTION
    Sets the background image for the Windows Lock Screen and Logon screen. Optionally enables or disables the blur (acrylic) effect. Supports local and remote systems.

.PARAMETER ImagePath
    Specifies the local path on the target computer for the lock screen image.

.PARAMETER EnableBlur
    If set, enables the acrylic blur effect on the logon screen.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Set-LogOnWallpaperRemote.ps1 -ImagePath "C:\Windows\Web\Screen\img105.jpg"

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$ImagePath,

    [bool]$EnableBlur = $true,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Path, $Blur)
            $regPathPers = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
            $regPathSys = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            
            if (-not (Test-Path $regPathPers)) {
                New-Item -Path $regPathPers -Force | Out-Null
            }
            if (-not (Test-Path $regPathSys)) {
                New-Item -Path $regPathSys -Force | Out-Null
            }
            
            Set-ItemProperty -Path $regPathPers -Name "LockScreenImage" -Value $Path -Force -ErrorAction Stop
            
            $blurValue = if ($Blur) { 0 } else { 1 }
            Set-ItemProperty -Path $regPathSys -Name "DisableAcrylicBackgroundOnLogon" -Value $blurValue -Force -ErrorAction Stop
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = @($ImagePath, $EnableBlur)
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            Invoke-Command @invokeParams
        }
        else {
            &$scriptBlock -Path $ImagePath -Blur $EnableBlur
        }

        $result = [PSCustomObject]@{
            ImagePath    = $ImagePath
            BlurEnabled  = $EnableBlur
            ComputerName = $ComputerName
            Action       = "LockScreenConfigured"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
