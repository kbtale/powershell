<#
.SYNOPSIS
	Computers: Lists disabled or inactive Active Directory computers
.DESCRIPTION
	Lists computers where disabled or inactive in a specified OU.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Disabled
	Shows the disabled computers.
.PARAMETER InActive
	Shows the inactive computers.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-ComputerWithDefinedStatus.ps1 -Disabled -OUPath "OU=Computers,DC=contoso,DC=com"
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
		'Server'        = $Domain.PDCEmulator
		'SearchBase'    = $OUPath
		'SearchScope'   = $SearchScope
	}
	if ($null -ne $DomainAccount) {
		$searchArgs.Add("Credential", $DomainAccount)
	}

	$results = @()

	if ($Disabled) {
		$disabledComputers = Search-ADAccount @searchArgs -AccountDisabled -ComputersOnly | 
			Select-Object @{n='Status';e={'Disabled'}}, DistinguishedName, SAMAccountName
		$results += $disabledComputers
	}

	if ($InActive) {
		$inactiveComputers = Search-ADAccount @searchArgs -AccountInactive -ComputersOnly | 
			Select-Object @{n='Status';e={'Inactive'}}, DistinguishedName, SAMAccountName
		$results += $inactiveComputers
	}

	if ($results.Count -gt 0) {
		Write-Output ($results | Sort-Object SAMAccountName)
	} else {
		Write-Output "No computers found with the specified status."
	}
} catch {
	Write-Error $_
	exit 1
}
