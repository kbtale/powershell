<#
.SYNOPSIS
	Computers: Gets the properties of an Active Directory computer
.DESCRIPTION
	Gets the properties of an Active Directory computer.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Computername
	DistinguishedName, DNSHostName or SamAccountName of the computer.
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
	PS> ./Get-ComputerProperty.ps1 -Computername "COMP01" -OUPath "OU=Computers,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Computername,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('*', 'Name', 'DistinguishedName', 'DNSHostName', 'Enabled', 'Description', 'IPv4Address', 'IPv6Address', 'LastLogonDate', 'LastBadPasswordAttempt', 'SID', 'Location', 'SAMAccountName', 'OperatingSystem', 'OperatingSystemServicePack', 'CanonicalName', 'AccountExpires')]
	[string[]]$Properties = @('Name', 'DistinguishedName', 'DNSHostName', 'Enabled', 'Description', 'IPv4Address', 'IPv6Address', 'LastBadPasswordAttempt', 'Location', 'OperatingSystem', 'SAMAccountName'),

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

	$sam = $Computername
	if (-not $sam.EndsWith('$')) {
		$sam += '$'
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
		'AuthType'    = $AuthType
		'Filter'      = "(SamAccountName -eq '$sam') -or (DNSHostName -eq '$Computername') -or (DistinguishedName -eq '$Computername')"
		'Server'      = $Domain.PDCEmulator
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Properties'  = '*'
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
	}
	
	$cmp = Get-ADComputer @getArgs

	if ($null -ne $cmp) {
		$result = [ordered]@{}
		if ($Properties -eq '*') {
			foreach ($prop in $cmp.PropertyNames) {
				$result[$prop] = $cmp[$prop]
			}
		} else {
			foreach ($prop in $Properties) {
				$trimmedProp = $prop.Trim()
				$result[$trimmedProp] = $cmp[$trimmedProp]
			}
		}
		Write-Output ([PSCustomObject]$result)
	} else {
		throw "Computer '$Computername' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
