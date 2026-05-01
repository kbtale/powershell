<#
.SYNOPSIS
	Reports: Generates a report with properties of Active Directory computers
.DESCRIPTION
	Retrieves property information for one or all computer accounts within a specified OU.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Computername
	DistinguishedName, DNSHostName or SamAccountName of the computer.
.PARAMETER Properties
	List of properties to include in the report. Use * for all properties.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Get-ComputerPropertyReport.ps1 -OUPath "OU=Computers,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Computername,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('*', 'Name', 'DistinguishedName', 'DNSHostName', 'Enabled', 'Description', 'IPv4Address', 'IPv6Address', 'LastLogonDate', 'LastBadPasswordAttempt', 'SID', 'Location', 'SAMAccountName', 'OperatingSystem', 'OperatingSystemServicePack', 'CanonicalName', 'AccountExpires')]
	[string[]]$Properties = @('Name', 'Enabled', 'IPv4Address', 'OperatingSystem', 'SAMAccountName', 'DistinguishedName'),

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

	$searchArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
		'Filter'      = '*'
		'Properties'  = $Properties
	}
	if ($null -ne $DomainAccount) { $searchArgs.Add("Credential", $DomainAccount) }

	if (-not [string]::IsNullOrWhiteSpace($Computername)) {
		[string]$sam = $Computername
		if (-not $sam.EndsWith('$')) { $sam += '$' }
		$searchArgs['Filter'] = "(SamAccountName -eq '$sam') -or (DNSHostName -eq '$Computername') -or (DistinguishedName -eq '$Computername')"
	}

	$cmp = Get-ADComputer @searchArgs | Sort-Object Name | Select-Object $Properties
	Write-Output $cmp
} catch {
	Write-Error $_
	exit 1
}
