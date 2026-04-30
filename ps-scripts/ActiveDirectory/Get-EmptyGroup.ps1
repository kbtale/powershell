<#
.SYNOPSIS
	Groups: Gets Active Directory groups without members
.DESCRIPTION
	Lists all groups in a specified OU that do not have any members.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-EmptyGroup.ps1 -OUPath "OU=Groups,DC=contoso,DC=com"
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

	$getArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Filter'      = '*'
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Properties'  = 'Members'
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}
	
	$emptyGroups = Get-ADGroup @getArgs | Where-Object { $_.Members.Count -eq 0 } | 
		Select-Object DistinguishedName, SamAccountName | Sort-Object SamAccountName

	if ($null -ne $emptyGroups) {
		Write-Output $emptyGroups
	} else {
		Write-Output "No empty groups found in OU '$OUPath'."
	}
} catch {
	Write-Error $_
	exit 1
}
