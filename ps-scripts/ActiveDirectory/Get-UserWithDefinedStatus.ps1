<#
.SYNOPSIS
	Users: Lists users with specific status (disabled, inactive, locked, expired)
.DESCRIPTION
	Searches for Active Directory user accounts that meet specified criteria such as being disabled, inactive, locked out, or expired.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Disabled
	Includes disabled user accounts in the results.
.PARAMETER InActive
	Includes inactive user accounts in the results.
.PARAMETER Locked
	Includes locked out user accounts in the results.
.PARAMETER Expired
	Includes expired user accounts in the results.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-UserWithDefinedStatus.ps1 -Disabled -Locked -OUPath "OU=Users,DC=contoso,DC=com"
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

	if ($Disabled) {
		$results += Search-ADAccount @searchArgs -AccountDisabled | Select-Object @{n='Status';e={'Disabled'}}, Name, SamAccountName, DistinguishedName
	}
	if ($InActive) {
		$results += Search-ADAccount @searchArgs -AccountInactive | Select-Object @{n='Status';e={'Inactive'}}, Name, SamAccountName, DistinguishedName
	}
	if ($Locked) {
		$results += Search-ADAccount @searchArgs -LockedOut | Select-Object @{n='Status';e={'Locked'}}, Name, SamAccountName, DistinguishedName
	}
	if ($Expired) {
		$results += Search-ADAccount @searchArgs -AccountExpired | Select-Object @{n='Status';e={'Expired'}}, Name, SamAccountName, DistinguishedName
	}

	if ($results.Count -gt 0) {
		Write-Output ($results | Sort-Object Status, SamAccountName)
	} else {
		Write-Output "No users found matching the specified criteria."
	}
} catch {
	Write-Error $_
	exit 1
}
