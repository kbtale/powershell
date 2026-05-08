#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Create a custom policy package
.DESCRIPTION
    Creates a custom policy package with a custom name, description, and list of policies.
.PARAMETER Identity
    Name of the custom package
.PARAMETER PolicyList
    List of policies included in the package, semicolon separated. Format: "<PolicyType>, <PolicyName>"
.PARAMETER Description
    Description of the custom package
.EXAMPLE
    PS> ./New-MSTCustomPolicyPackage.ps1 -Identity "MyCustomPackage" -PolicyList "TeamsMeetingPolicy, MyMeetingPolicy" -Description "Custom policy"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [Parameter(Mandatory = $true)]
    [string]$PolicyList,
    [string]$Description
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'Identity' = $Identity; 'PolicyList' = $PolicyList}

        if (-not [System.String]::IsNullOrWhiteSpace($Description)) {
            $cmdArgs.Add('Description', $Description)
        }

        $result = New-CsCustomPolicyPackage @cmdArgs | Select-Object *

        if ($null -eq $result) {
            Write-Output "Custom policy package created"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
