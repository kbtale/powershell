<#
.SYNOPSIS
	Reports: Generates a report with disabled or inactive Active Directory computers
.DESCRIPTION
	Identifies computer accounts that are disabled or inactive within a specified Active Directory OU.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Disabled
	Include disabled computers in the report.
.PARAMETER InActive
	Include inactive computers in the report.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-ComputerStatusReport.ps1 -OUPath "OU=Computers,DC=contoso,DC=com" -Disabled -InActive
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$Disabled,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$InActive,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DomainName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('Base', 'OneLevel', 'SubTree')]
	[string]$SearchScope = 'SubTree',

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('Basic', 'Negotiate')]
	[string]$AuthType = "Negotiate"
)

try {
	Import-Module ActiveDirectory -ErrorAction Stop

	[hashtable]$cmdArgs = @{
		'ErrorAction' = 'Stop'
		'AuthType'    = $AuthType
	}
	if ($null -ne $DomainAccount) {
		$cmdArgs.Add("Credential", $DomainAccount)
	}
	if ([System.String]::IsNullOrWhiteSpace($DomainName)) {
		$cmdArgs.Add("Current", 'LocalComputer')
	} else {
		$cmdArgs.Add("Identity", $DomainName)
	}
	$Domain = Get-ADDomain @cmdArgs

	$searchArgs = @{
		'ErrorAction'   = 'Stop'
		'AuthType'      = $AuthType
		'ComputersOnly' = $true
		'Server'        = $Domain.PDCEmulator
		'SearchBase'    = $OUPath
		'SearchScope'   = $SearchScope
	}
	if ($null -ne $DomainAccount) { $searchArgs.Add("Credential", $DomainAccount) }

	$results = @()
	if ($Disabled) {
		$results += Search-ADAccount @searchArgs -AccountDisabled | Select-Object @{n='Status';e={'Disabled'}}, SAMAccountName, Name, LastLogonDate, PasswordExpired, DistinguishedName
	}
	if ($InActive) {
		$results += Search-ADAccount @searchArgs -AccountInactive | Select-Object @{n='Status';e={'InActive'}}, SAMAccountName, Name, LastLogonDate, PasswordExpired, DistinguishedName
	}

	if ($results.Count -gt 0) {
		Write-Output ($results | Sort-Object SAMAccountName)
	} else {
		Write-Output "No disabled or inactive computers found in '$OUPath'."
	}
} catch {
	Write-Error $_
	exit 1
}
