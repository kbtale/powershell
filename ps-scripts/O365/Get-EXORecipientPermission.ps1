#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online Management: Gets SendAs permissions configured for users
.DESCRIPTION
    Retrieves information about SendAs permissions configured for users in a cloud-based organization using the EXO V2 module.
.PARAMETER Identity
    Name, Alias or SamAccountName of the target recipient
.PARAMETER Trustee
    Filters results by the user or group to whom the permission is granted
.PARAMETER ResultSize
    Maximum number of results to return
.EXAMPLE
    PS> ./Get-EXORecipientPermission.ps1
.EXAMPLE
    PS> ./Get-EXORecipientPermission.ps1 -Identity "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$Identity,
    [string]$Trustee,
    [int]$ResultSize = 1000
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'ResultSize' = $ResultSize}

        if (-not [System.String]::IsNullOrWhiteSpace($Identity)) {
            $cmdArgs.Add('Identity', $Identity)
        }
        if ($PSBoundParameters.ContainsKey('Trustee')) {
            $cmdArgs.Add('Trustee', $Trustee)
        }

        $result = Get-EXORecipientPermission @cmdArgs
        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No recipient permissions found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
