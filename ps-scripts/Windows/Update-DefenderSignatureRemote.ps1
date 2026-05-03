#Requires -Version 5.1
#Requires -Modules Defender

<#
.SYNOPSIS
    Windows: Updates Windows Defender antimalware definitions

.DESCRIPTION
    Triggers a definition update for Windows Defender Antivirus on a local or remote computer. Supports specifying the update source.

.PARAMETER UpdateSource
    Specifies the source for the update. Valid values: InternalDefinitionUpdateServer, MicrosoftUpdateServer, MMPC, FileShares.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Update-DefenderSignatureRemote.ps1 -UpdateSource MicrosoftUpdateServer

.CATEGORY Windows
#>

[CmdletBinding()]
Param (
    [ValidateSet('InternalDefinitionUpdateServer', 'MicrosoftUpdateServer', 'MMPC', 'FileShares')]
    [string]$UpdateSource = "MicrosoftUpdateServer",

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $session = $null
        if ($ComputerName -ne $env:COMPUTERNAME) {
            $sessionParams = @{
                'ComputerName' = $ComputerName
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $sessionParams.Add('Credential', $Credential)
            }
            $session = New-CimSession @sessionParams
            Update-MpSignature -CimSession $session -UpdateSource $UpdateSource -ErrorAction Stop
        }
        else {
            Update-MpSignature -UpdateSource $UpdateSource -ErrorAction Stop
        }

        $status = if ($session) { Get-MpComputerStatus -CimSession $session } else { Get-MpComputerStatus }

        $result = [PSCustomObject]@{
            AntivirusSignatureVersion = $status.AntivirusSignatureVersion
            AntispywareSignatureVersion = $status.AntispywareSignatureVersion
            ComputerName               = $ComputerName
            Action                     = "SignatureUpdateCompleted"
            Status                     = "Success"
            Timestamp                  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $session) {
            Remove-CimSession $session
        }
    }
}
