#Requires -Version 5.1
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Print Management: Gets the permissions of a printer from the specified computer.
.DESCRIPTION
    Retrieves the security permissions (ACL) of a printer from the specified computer.
.PARAMETER ComputerName
    Name of the computer on which the printer is installed.
.PARAMETER AccessAccount
    User account that has permission to perform this action.
.PARAMETER PrinterName
    Name of the printer from which to retrieve the permissions.
.EXAMPLE
    PS> ./Get-PrinterPermissions.ps1 -ComputerName "PC01" -PrinterName "MyPrinter"
.CATEGORY WinPrintManagement
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

Process {
    try {
        if ([System.String]::IsNullOrWhiteSpace($ComputerName)) { $ComputerName = [System.Net.DNS]::GetHostByName('').HostName }
        $cim = if ($null -eq $AccessAccount) { New-CimSession -ComputerName $ComputerName -ErrorAction Stop }
               else { New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop }
        $printer = Get-Printer -Name $PrinterName -ComputerName $ComputerName -CimSession $cim -Full -ErrorAction Stop
        $output = @()
        if ($null -ne $printer) {
            $secDesc = New-Object Security.AccessControl.CommonSecurityDescriptor($true, $false, $printer.PermissionSDDL)
            $secDesc.DiscretionaryAcl | ForEach-Object {
                $mask = $_.AccessMask
                $desc = @()
                if (($mask -band 131080) -eq 131080) { $desc += 'Print' }
                if (($mask -band 524288) -eq 524288) { $desc += 'Takeownership' }
                if (($mask -band 131072) -eq 131072) { $desc += 'ReadPermissions' }
                if (($mask -band 262144) -eq 262144) { $desc += 'ChangePermissions' }
                if (($mask -band 983052) -eq 983052) { $desc += 'ManagePrinters' }
                if (($mask -band 983088) -eq 983088) { $desc += 'ManageDocuments' }
                if (($mask -band 268435456) -eq 268435456) { $desc += 'FullControl' }
                $aceDesc = $desc -join ', '
                if (-not [System.String]::IsNullOrWhiteSpace($aceDesc)) {
                    $sid = New-Object System.Security.Principal.SecurityIdentifier($_.SecurityIdentifier)
                    $user = $sid.Translate([System.Security.Principal.NTAccount])
                    $output += [PSCustomObject]@{
                        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        Principal = $user.Value
                        AceQualifier = $_.AceQualifier
                        AceType = $_.AceType
                        AceFlags = $_.AceFlags
                        AccessMask = $aceDesc
                    }
                }
            }
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $cim) { Remove-CimSession $cim -ErrorAction SilentlyContinue } }
}
