#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Delete a custom policy package
.DESCRIPTION
    Deletes a custom policy package by its name.
.PARAMETER Identity
    Name of the custom package to delete
.EXAMPLE
    PS> ./Remove-MSTCustomPolicyPackage.ps1 -Identity "MyCustomPackage"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        $result = Remove-CsCustomPolicyPackage @cmdArgs

        [PSCustomObject]@{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Identity  = $Identity
            Status    = if ($null -eq $result) { 'Custom policy package removed' } else { $result.ToString() }
        }
    }
    catch { throw }
}
