<#
.SYNOPSIS
	Reports: Generates a report with disabled, inactive, locked out, or expired Active Directory users
.DESCRIPTION
	Identifies and lists user accounts that are disabled, inactive, locked out, or expired within a specified Active Directory OU.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Disabled
	Include disabled users in the report.
.PARAMETER InActive
	Include inactive users in the report.
.PARAMETER Locked
	Include locked out users in the report.
.PARAMETER Expired
	Include expired user accounts in the report.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-UserStatusReport.ps1 -OUPath "OU=Users,DC=contoso,DC=com" -Disabled -Locked
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$Disabled,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$InActive,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$Locked,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$Expired,

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
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'UsersOnly'   = $true
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
	}
	if ($null -ne $DomainAccount) { $searchArgs.Add("Credential", $DomainAccount) }

	$results = @()
	if ($Locked) {
		$results += Search-ADAccount @searchArgs -LockedOut | Select-Object @{n='Status';e={'Locked'}}, SAMAccountName, CN, LastLogonDate, PasswordExpired, Enabled, DistinguishedName
	}
	if ($Expired) {
		$results += Search-ADAccount @searchArgs -AccountExpired | Select-Object @{n='Status';e={'Expired'}}, SAMAccountName, CN, LastLogonDate, PasswordExpired, Enabled, DistinguishedName
	}
	if ($Disabled) {
		$results += Search-ADAccount @searchArgs -AccountDisabled | Select-Object @{n='Status';e={'Disabled'}}, SAMAccountName, CN, LastLogonDate, PasswordExpired, Enabled, DistinguishedName
	}
	if ($InActive) {
		$results += Search-ADAccount @searchArgs -AccountInactive | Select-Object @{n='Status';e={'InActive'}}, SAMAccountName, CN, LastLogonDate, PasswordExpired, Enabled, DistinguishedName
	}

	if ($results.Count -gt 0) {
		Write-Output ($results | Sort-Object SAMAccountName)
	} else {
		Write-Output "No users matching the specified status criteria found in '$OUPath'."
	}
} catch {
	Write-Error $_
	exit 1
}
