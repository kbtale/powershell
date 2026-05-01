<#
.SYNOPSIS
	Groups: Gets the properties of an Active Directory group
.DESCRIPTION
	Retrieves the properties of a specified Active Directory group.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	DistinguishedName or SamAccountName of the Active Directory group.
.PARAMETER Properties
	List of properties to expand. Use * for all properties.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-GroupProperty.ps1 -GroupName "Domain Admins" -OUPath "DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$GroupName,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('*', 'Name', 'Description', 'DistinguishedName', 'HomePage', 'SAMAccountName', 'SID', 'CN', 'GroupCategory', 'CanonicalName', 'GroupScope', 'Members', 'MemberOf')]
	[string[]]$Properties = @('Name', 'Description', 'DistinguishedName', 'HomePage', 'SAMAccountName', 'SID'),

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

	if ($Properties -contains '*') {
		$Properties = @('*')
	}

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
		'Filter'      = "(SamAccountName -eq '$GroupName') -or (DistinguishedName -eq '$GroupName')"
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Properties'  = '*'
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}

	$grp = Get-ADGroup @getArgs
	if ($null -ne $grp) {
		$result = [ordered]@{}
		if ($Properties -eq '*') {
			foreach ($prop in $grp.PropertyNames) {
				$result[$prop] = $grp[$prop]
			}
		} else {
			foreach ($prop in $Properties) {
				$trimmedProp = $prop.Trim()
				$result[$trimmedProp] = $grp[$trimmedProp]
			}
		}
		Write-Output ([PSCustomObject]$result)
	} else {
		throw "Group '$GroupName' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
