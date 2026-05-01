<#
.SYNOPSIS
	Groups: Creates an Active Directory group
.DESCRIPTION
	Creates a new group object in Active Directory.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	Specifies the name of the new group.
.PARAMETER SAMAccountName
	Specifies the SAM account name of the group. If not provided, GroupName is used.
.PARAMETER Description
	Specifies a description of the group.
.PARAMETER DisplayName
	Specifies the display name of the group.
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
	PS> ./New-Group.ps1 -GroupName "Engineering" -OUPath "OU=Groups,DC=contoso,DC=com" -Scope "Global" -Category "Security"
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
	[string]$SAMAccountName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Description,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DisplayName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('DomainLocal', 'Global', 'Universal')]
	[string]$Scope = 'Universal',

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[ValidateSet('Distribution', 'Security')]
	[string]$Category = 'Security',

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

	$newArgs = @{
		'ErrorAction'   = 'Stop'
		'Server'        = $Domain.PDCEmulator
		'AuthType'      = $AuthType
		'PassThru'      = $true
		'Confirm'       = $false
		'Path'          = $OUPath
		'Name'          = $GroupName
		'GroupScope'    = $Scope
		'GroupCategory' = $Category
	}
	if ($null -ne $DomainAccount) {
		$newArgs.Add("Credential", $DomainAccount)
	}
	
	if ([string]::IsNullOrWhiteSpace($SAMAccountName)) {
		$newArgs['SamAccountName'] = $GroupName
	} else {
		$newArgs['SamAccountName'] = $SAMAccountName
	}
	
	if ($PSBoundParameters.ContainsKey('Description')) { $newArgs['Description'] = $Description }
	if ($PSBoundParameters.ContainsKey('DisplayName')) { $newArgs['DisplayName'] = $DisplayName }

	$grp = New-ADGroup @newArgs
	Write-Output $grp
} catch {
	Write-Error $_
	exit 1
}
