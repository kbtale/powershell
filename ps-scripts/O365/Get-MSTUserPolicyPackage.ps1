#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get the policy package assigned to a user
.DESCRIPTION
    Retrieves the policy package that is assigned to a specified user.
.PARAMETER Identity
    The user that will get their assigned policy package
.EXAMPLE
    PS> ./Get-MSTUserPolicyPackage.ps1 -Identity "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        $result = Get-CsUserPolicyPackage @getArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "No policy package assigned to user"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
