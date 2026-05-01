<#
.SYNOPSIS
	Users: Creates a new Active Directory user
.DESCRIPTION
	Creates a new user object in a specified Active Directory OU with the provided attributes.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GivenName
	Specifies the user's first name.
.PARAMETER Surname
	Specifies the user's last name.
.PARAMETER Password
	Specifies the initial password for the account.
.PARAMETER SAMAccountName
	Specifies the SAM account name. If omitted, it defaults to GivenName.Surname.
.PARAMETER UserPrincipalName
	Specifies the UPN. If omitted, it defaults to GivenName.Surname@Domain.
.PARAMETER UserName
	Specifies the name of the user object (CN).
.PARAMETER DisplayName
	Specifies the display name.
.PARAMETER Description
	Specifies a description for the user.
.PARAMETER EmailAddress
	Specifies the email address.
.PARAMETER ChangePasswordAtLogon
	Specifies whether the user must change their password at next logon.
.PARAMETER CannotChangePassword
	Specifies whether the user is prevented from changing their password.
.PARAMETER PasswordNeverExpires
	Specifies whether the password never expires.
.PARAMETER Department
	Specifies the user's department.
.PARAMETER Company
	Specifies the user's company.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method (Basic or Negotiate).
.EXAMPLE
	PS> ./New-User.ps1 -GivenName "John" -Surname "Doe" -Password (ConvertTo-SecureString "P@ssword123" -AsPlainText -Force) -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$GivenName,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Surname,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[securestring]$Password,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$SAMAccountName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$UserPrincipalName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$UserName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DisplayName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Description,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$EmailAddress,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$ChangePasswordAtLogon,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$CannotChangePassword,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$PasswordNeverExpires,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Department,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Company,

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

	if ([string]::IsNullOrWhiteSpace($SAMAccountName)) {
		$SAMAccountName = "$GivenName.$Surname"
	}
	if ($SAMAccountName.Length -gt 20) {
		$SAMAccountName = $SAMAccountName.Substring(0, 20)
	}
	if ([string]::IsNullOrWhiteSpace($UserName)) {
		$UserName = "${GivenName}_$Surname"
	}
	if ([string]::IsNullOrWhiteSpace($DisplayName)) {
		$DisplayName = "$GivenName, $Surname"
	}
	if ([string]::IsNullOrWhiteSpace($UserPrincipalName)) {
		$UserPrincipalName = "$GivenName.$Surname@$($Domain.DNSRoot)"
	}
	if ([string]::IsNullOrWhiteSpace($EmailAddress)) {
		$EmailAddress = "$GivenName.$Surname@$($Domain.DNSRoot)"
	}

	$newArgs = @{
		'ErrorAction'           = 'Stop'
		'Server'                = $Domain.PDCEmulator
		'AuthType'              = $AuthType
		'Name'                  = $UserName
		'UserPrincipalName'     = $UserPrincipalName
		'DisplayName'           = $DisplayName
		'GivenName'             = $GivenName
		'Surname'               = $Surname
		'EmailAddress'          = $EmailAddress
		'Path'                  = $OUPath
		'SamAccountName'        = $SAMAccountName
		'AccountPassword'       = $Password
		'Confirm'               = $false
		'Description'           = $Description
		'Department'            = $Department
		'Company'               = $Company
		'ChangePasswordAtLogon' = $ChangePasswordAtLogon
		'PasswordNeverExpires'  = $PasswordNeverExpires
		'CannotChangePassword'  = $CannotChangePassword
		'Enabled'               = $true
		'PassThru'              = $true
	}
	if ($null -ne $DomainAccount) { $newArgs.Add("Credential", $DomainAccount) }

	$newUser = New-ADUser @newArgs
	Write-Output "User '$($newUser.Name)' created successfully."
	Write-Output $newUser
} catch {
	Write-Error $_
	exit 1
}
