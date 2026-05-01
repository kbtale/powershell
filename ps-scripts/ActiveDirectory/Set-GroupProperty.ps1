<#
.SYNOPSIS
	Groups: Sets the properties of an Active Directory group
.DESCRIPTION
	Updates the properties of an existing group object in Active Directory. Only provided parameters are updated.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	DistinguishedName or SamAccountName of the Active Directory group.
.PARAMETER DisplayName
	Specifies the display name of the group.
.PARAMETER Description
	Specifies a description of the group.
.PARAMETER HomePage
	Specifies the home page of the group.
.PARAMETER Scope
	Specifies the group scope (DomainLocal, Global, Universal).
.PARAMETER Category
	Specifies the category (Distribution, Security).
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Set-GroupProperty.ps1 -GroupName "Engineering" -Description "Engineering Department Group" -OUPath "OU=Groups,DC=contoso,DC=com"
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
	[string]$DisplayName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Description,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$HomePage,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('DomainLocal', 'Global', 'Universal')]
	[string]$Scope,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('Distribution', 'Security')]
	[string]$Category,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DomainName,

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

	$setArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Identity'    = $GroupName
		'Confirm'     = $false
	}
	if ($null -ne $DomainAccount) {
		$setArgs.Add("Credential", $DomainAccount)
	}
	
	if ($PSBoundParameters.ContainsKey('Scope')) { $setArgs['GroupScope'] = $Scope }
	if ($PSBoundParameters.ContainsKey('Category')) { $setArgs['GroupCategory'] = $Category }
	if ($PSBoundParameters.ContainsKey('Description')) { $setArgs['Description'] = $Description }
	if ($PSBoundParameters.ContainsKey('DisplayName')) { $setArgs['DisplayName'] = $DisplayName }
	if ($PSBoundParameters.ContainsKey('HomePage')) { $setArgs['HomePage'] = $HomePage }

	Set-ADGroup @setArgs
	Write-Output "Properties for group '$GroupName' updated successfully."
} catch {
	Write-Error $_
	exit 1
}
