#Requires -Version 5.1

<#
.SYNOPSIS
    Reporting: Generates an HTML report of Active Directory objects
.DESCRIPTION
    Generates an HTML report from Active Directory object data.
.PARAMETER ObjectType
    Type of AD object: User, Group, Computer
.PARAMETER SearchBase
    Distinguished name of the search base OU
.PARAMETER Properties
    List of properties to include
.EXAMPLE
    PS> ./New-ADReport.ps1 -ObjectType User -SearchBase "OU=Users,DC=contoso,DC=com" | Out-File adreport.html
.CATEGORY Reporting
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('User', 'Group', 'Computer')]
    [string]$ObjectType,

    [Parameter(Mandatory = $true)]
    [string]$SearchBase,

    [string[]]$Properties
)

Process {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop

        $cmdArgs = @{ ErrorAction = 'Stop'; SearchBase = $SearchBase }
        if ($PSBoundParameters.ContainsKey('Properties')) { $cmdArgs.Add('Properties', $Properties) }

        $result = switch ($ObjectType) {
            'User' { Get-ADUser -Filter * @cmdArgs | Select-Object Name, SamAccountName, UserPrincipalName, Enabled, Department, Title }
            'Group' { Get-ADGroup -Filter * @cmdArgs | Select-Object Name, SamAccountName, GroupCategory, GroupScope, Description }
            'Computer' { Get-ADComputer -Filter * @cmdArgs | Select-Object Name, SamAccountName, OperatingSystem, Enabled, LastLogonDate }
        }

        if ($null -ne $result) {
            $html = $result | ConvertTo-Html -Head "<style>body{font-family:Arial} table{border-collapse:collapse} th,td{border:1px solid #ddd;padding:8px} th{background-color:#0078D4;color:white}</style>"
            Write-Output $html
        }
        else { Write-Output "No objects found" }
    }
    catch { throw }
}
