#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get policy package recommendations for a user
.DESCRIPTION
    Retrieves policy package recommendations available for a specified user based on their role and activity.
.PARAMETER Identity
    The user that will receive policy package recommendations
.EXAMPLE
    PS> ./Get-MSTUserPolicyPackageRecommendation.ps1 -Identity "user@domain.com"
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

        $result = Get-CsUserPolicyPackageRecommendation @getArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No policy package recommendations found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
