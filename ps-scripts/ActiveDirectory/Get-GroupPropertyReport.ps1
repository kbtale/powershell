<#
.SYNOPSIS
	Reports: Generates a report with properties of Active Directory groups
.DESCRIPTION
	Retrieves property information for one or all group objects within a specified Active Directory OU.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	DistinguishedName or SamAccountName of the group.
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
	PS> ./Get-GroupPropertyReport.ps1 -OUPath "OU=Groups,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$GroupName,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DomainName,

	[ValidateSet('*', 'Name', 'DistinguishedName', 'SamAccountName', 'SID', 'GroupCategory', 'GroupScope', 'Members', 'MemberOf', 'ObjectClass', 'ObjectGUID')]
	[string[]]$Properties = @('Name', 'SamAccountName', 'SID', 'DistinguishedName'),

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
		'Properties'  = $Properties
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }

	if (-not [string]::IsNullOrWhiteSpace($GroupName)) {
		$getArgs.Add("Identity", $GroupName)
	} else {
		$getArgs.Add("Filter", '*')
		$getArgs.Add("SearchBase", $OUPath)
		$getArgs.Add("SearchScope", $SearchScope)
	}

	$grps = Get-ADGroup @getArgs | Sort-Object SamAccountName | Select-Object $Properties
	Write-Output $grps
} catch {
	Write-Error $_
	exit 1
}
