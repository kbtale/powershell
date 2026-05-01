<#
.SYNOPSIS
	Users: Sets the properties of an Active Directory user
.DESCRIPTION
	Updates the properties of an existing user account in Active Directory. Only provided parameters are updated.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Username
	Display name, SAMAccountName, DistinguishedName or user principal name of the user.
.PARAMETER GivenName
	Specifies the user's given name.
.PARAMETER Surname
	Specifies the user's last name or surname.
.PARAMETER DisplayName
	Specifies the display name of the user.
.PARAMETER Description
	Specifies a description of the user.
.PARAMETER Office
	Specifies the office location.
.PARAMETER EmailAddress
	Specifies the e-mail address.
.PARAMETER Phone
	Specifies the office telephone number.
.PARAMETER Title
	Specifies the user's title.
.PARAMETER Department
	Specifies the user's department.
.PARAMETER Company
	Specifies the user's company.
.PARAMETER Street
	Specifies the street address.
.PARAMETER PostalCode
	Specifies the postal code.
.PARAMETER City
	Specifies the town or city.
.PARAMETER CannotChangePassword
	Specifies whether the user can change their password.
.PARAMETER PasswordNeverExpires
	Specifies whether the password expires.
.PARAMETER ChangePasswordAtLogon
	Specifies whether the user must change password at next logon.
.PARAMETER NewSAMAccountName
	Specifies a new SAMAccountName for the user.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Set-UserProperty.ps1 -Username "jdoe" -Title "Senior Engineer" -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Username,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$GivenName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Surname,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DisplayName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Description,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Office,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$EmailAddress,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Phone,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Title,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Department,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Company,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Street,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$PostalCode,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$City,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[bool]$CannotChangePassword,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[bool]$PasswordNeverExpires,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[bool]$ChangePasswordAtLogon,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$NewSAMAccountName,

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
		'Filter'      = "SamAccountName -eq '$Username' -or DisplayName -eq '$Username' -or DistinguishedName -eq '$Username' -or UserPrincipalName -eq '$Username'"
		'SearchBase'  = $OUPath
		'SearchScope' = $SearchScope
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }
	$usr = Get-ADUser @getArgs
	
	if ($null -ne $usr) {
		$setArgs = @{
			'ErrorAction' = 'Stop'
			'Server'      = $Domain.PDCEmulator
			'AuthType'    = $AuthType
			'Identity'    = $usr.DistinguishedName
			'Confirm'     = $false
		}
		if ($null -ne $DomainAccount) { $setArgs.Add("Credential", $DomainAccount) }

		if ($PSBoundParameters.ContainsKey('GivenName')) { $setArgs['GivenName'] = $GivenName }
		if ($PSBoundParameters.ContainsKey('Surname')) { $setArgs['Surname'] = $Surname }
		if ($PSBoundParameters.ContainsKey('DisplayName')) { $setArgs['DisplayName'] = $DisplayName }
		if ($PSBoundParameters.ContainsKey('Description')) { $setArgs['Description'] = $Description }
		if ($PSBoundParameters.ContainsKey('Office')) { $setArgs['Office'] = $Office }
		if ($PSBoundParameters.ContainsKey('EmailAddress')) { $setArgs['EmailAddress'] = $EmailAddress }
		if ($PSBoundParameters.ContainsKey('Phone')) { $setArgs['OfficePhone'] = $Phone }
		if ($PSBoundParameters.ContainsKey('Title')) { $setArgs['Title'] = $Title }
		if ($PSBoundParameters.ContainsKey('Department')) { $setArgs['Department'] = $Department }
		if ($PSBoundParameters.ContainsKey('Company')) { $setArgs['Company'] = $Company }
		if ($PSBoundParameters.ContainsKey('Street')) { $setArgs['StreetAddress'] = $Street }
		if ($PSBoundParameters.ContainsKey('PostalCode')) { $setArgs['PostalCode'] = $PostalCode }
		if ($PSBoundParameters.ContainsKey('City')) { $setArgs['City'] = $City }
		if ($PSBoundParameters.ContainsKey('CannotChangePassword')) { $setArgs['CannotChangePassword'] = $CannotChangePassword }
		if ($PSBoundParameters.ContainsKey('PasswordNeverExpires')) { $setArgs['PasswordNeverExpires'] = $PasswordNeverExpires }
		if ($PSBoundParameters.ContainsKey('ChangePasswordAtLogon')) { $setArgs['ChangePasswordAtLogon'] = $ChangePasswordAtLogon }

		Set-ADUser @setArgs

		if ($PSBoundParameters.ContainsKey('NewSAMAccountName')) {
			Set-ADUser -Identity $usr.DistinguishedName -Replace @{ SamAccountName = $NewSAMAccountName } -Server $Domain.PDCEmulator -AuthType $AuthType -ErrorAction Stop
		}

		Write-Output "Properties for user '$Username' updated successfully."
	} else {
		throw "User '$Username' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
