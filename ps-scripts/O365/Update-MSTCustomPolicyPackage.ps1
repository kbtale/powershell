#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Update a custom policy package
.DESCRIPTION
    Updates an existing custom policy package with new settings.
.PARAMETER Identity
    Name of the custom package to update
.PARAMETER PolicyList
    Updated list of policies in the package, semicolon separated
.PARAMETER Description
    Updated description of the custom package
.EXAMPLE
    PS> ./Update-MSTCustomPolicyPackage.ps1 -Identity "MyCustomPackage" -PolicyList "TeamsMeetingPolicy, UpdatedPolicy" -Description "Updated description"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [string]$PolicyList,
    [string]$Description
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity}

        if (-not [System.String]::IsNullOrWhiteSpace($PolicyList)) {
            $cmdArgs.Add('PolicyList', $PolicyList)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
            $cmdArgs.Add('Description', $Description)
        }

        $result = Update-CsCustomPolicyPackage @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Custom policy package updated"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
