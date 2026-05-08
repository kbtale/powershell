#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get all policy packages available on the tenant
.DESCRIPTION
    Retrieves all policy packages available on the tenant. Supports optional filtering by policy name.
.PARAMETER Identity
    The name of a specific policy package to retrieve
.EXAMPLE
    PS> ./Get-MSTPolicyPackage.ps1
.EXAMPLE
    PS> ./Get-MSTPolicyPackage.ps1 -Identity "Education_Teacher"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$Identity
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}

        if (-not [System.String]::IsNullOrWhiteSpace($Identity)) {
            $getArgs.Add('Identity', $Identity)
        }

        $result = Get-CsPolicyPackage @getArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No policy packages found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
