#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures Hyper-V Replica settings on a host

.DESCRIPTION
    Enables, disables, and configures Microsoft Hyper-V Replica settings for a host, including authentication types, ports, and storage locations.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Enabled
    Specifies whether the host is enabled as a Replica server ($true) or disabled ($false).

.PARAMETER AuthenticationType
    Optional. Specifies the allowed authentication type (Kerberos, Certificate, or Integrated).

.PARAMETER KerberosPort
    Optional. Specifies the port for Kerberos (HTTP) authentication. Defaults to 80.

.PARAMETER CertificatePort
    Optional. Specifies the port for Certificate (HTTPS) authentication. Defaults to 443.

.PARAMETER CertificateThumbprint
    Optional. Specifies the thumbprint of the certificate for mutual authentication.

.PARAMETER DefaultStorageLocation
    Optional. Specifies the default folder for storing replicated virtual machines.

.PARAMETER AllowAnyServer
    Optional. If set to $true, allows replication from any authenticated server.

.EXAMPLE
    PS> ./Set-HyperVReplicationConfig.ps1 -Enabled $true -AuthenticationType Kerberos -AllowAnyServer $true

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [ValidateSet('Kerberos', 'Certificate', 'Integrated')]
    [string]$AuthenticationType,

    [int]$KerberosPort,

    [int]$CertificatePort,

    [string]$CertificateThumbprint,

    [string]$DefaultStorageLocation,

    [bool]$AllowAnyServer
)

Process {
    try {
        $params = @{
            'ComputerName'       = $ComputerName
            'ReplicationEnabled' = $Enabled
            'Confirm'            = $false
            'ErrorAction'        = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        
        if ($Enabled) {
            if ($AuthenticationType) { $params.Add('AllowedAuthenticationType', $AuthenticationType) }
            if ($PSBoundParameters.ContainsKey('KerberosPort')) { $params.Add('KerberosAuthenticationPort', $KerberosPort) }
            if ($PSBoundParameters.ContainsKey('CertificatePort')) { $params.Add('CertificateAuthenticationPort', $CertificatePort) }
            if ($CertificateThumbprint) { $params.Add('CertificateThumbprint', $CertificateThumbprint) }
            if ($DefaultStorageLocation) { $params.Add('DefaultStorageLocation', $DefaultStorageLocation) }
            if ($PSBoundParameters.ContainsKey('AllowAnyServer')) { $params.Add('ReplicationAllowedFromAnyServer', $AllowAnyServer) }
        }

        Set-VMReplicationServer @params

        $serverInfo = Get-VMReplicationServer -ComputerName $ComputerName -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            ComputerName              = $serverInfo.ComputerName
            ReplicationEnabled        = $serverInfo.ReplicationEnabled
            AllowedAuthenticationType = $serverInfo.AllowedAuthenticationType
            DefaultStorageLocation    = $serverInfo.DefaultStorageLocation
            Action                    = "ReplicationConfigUpdated"
            Status                    = "Success"
            Timestamp                 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
