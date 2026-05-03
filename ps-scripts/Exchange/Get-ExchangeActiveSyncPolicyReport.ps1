#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Generates a detailed audit report of ActiveSync Mailbox Policies

.DESCRIPTION
    Retrieves a comprehensive set of properties for all ActiveSync Mailbox Policies, enabling deep security auditing of mobile device policies.

.EXAMPLE
    PS> ./Get-ExchangeActiveSyncPolicyReport.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $policies = Get-ActiveSyncMailboxPolicy -ErrorAction Stop

        $results = foreach ($p in $policies) {
            [PSCustomObject]@{
                Name                               = $p.Name
                IsDefaultPolicy                   = $p.IsDefault
                AllowSimpleDevicePassword         = $p.AllowSimpleDevicePassword
                AlphanumericDevicePasswordRequired = $p.AlphanumericDevicePasswordRequired
                MinDevicePasswordLength           = $p.MinDevicePasswordLength
                MinDevicePasswordComplexCharacters = $p.MinDevicePasswordComplexCharacters
                PasswordRecoveryEnabled           = $p.PasswordRecoveryEnabled
                DevicePasswordEnabled             = $p.DevicePasswordEnabled
                AllowNonProvisionableDevices      = $p.AllowNonProvisionableDevices
                MaxDevicePasswordFailedAttempts   = $p.MaxDevicePasswordFailedAttempts
                AttachmentsEnabled                = $p.AttachmentsEnabled
                MaxAttachmentSize                 = $p.MaxAttachmentSize
                DistinguishedName                 = $p.DistinguishedName
                LastModified                      = $p.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
