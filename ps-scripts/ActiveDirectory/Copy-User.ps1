<#
.SYNOPSIS
	Users: Copy an Active Directory account
.DESCRIPTION
	Creates a new Active Directory user account by copying properties from an existing template user.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER SourceUsername
	Display name, SAMAccountName, DistinguishedName or UPN of the template user.
.PARAMETER GivenName
	Specifies the new user's given name.
.PARAMETER Surname
	Specifies the new user's last name or surname.
.PARAMETER Password
	Specifies the password value for the new account.
.PARAMETER SAMAccountName
	Specifies the SAM account name of the new user. If not provided, it is generated from name.
.PARAMETER UserPrincipalName
	Specifies the UPN of the new user.
.PARAMETER NewUserName
	Specifies the name (CN) of the new user.
.PARAMETER DisplayName
	Specifies the display name of the new user.
.PARAMETER EmailAddress
	Specifies the user's e-mail address.
.PARAMETER CopyGroupMemberships
	Copies the group memberships from the template user.
.PARAMETER ChangePasswordAtLogon
	Specifies whether a password must be changed during the next logon.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Copy-User.ps1 -SourceUsername "TemplateUser" -GivenName "John" -Surname "Doe" -OUPath "OU=Users,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$SourceUsername,

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
	[string]$NewUserName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DisplayName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$EmailAddress,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$CopyGroupMemberships,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$ChangePasswordAtLogon,

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

	$copyProperties = @('AccountExpirationDate', 'City', 'Company', 'Country', 'Department', 'Description', 'Division', 'Fax', 'HomeDirectory', 'HomeDrive', 'HomePage', 'HomePhone', 'Initials', 'ipPhone', 'Manager', 'MobilePhone', 'Office', 'OfficePhone', 'Organization', 'OtherName', 'pager', 'physicalDeliveryOfficeName', 'POBox', 'PostalCode', 'postOfficeBox', 'State', 'StreetAddress', 'telephoneNumber', 'Title', 'wWWHomePage')

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

	# Defaults for new user
	if ([string]::IsNullOrWhiteSpace($SAMAccountName)) {
		$SAMAccountName = "$GivenName.$Surname"
		if ($SAMAccountName.Length -gt 20) { $SAMAccountName = $SAMAccountName.Substring(0, 20) }
	}
	if ([string]::IsNullOrWhiteSpace($NewUserName)) { $NewUserName = "$GivenName $Surname" }
	if ([string]::IsNullOrWhiteSpace($DisplayName)) { $DisplayName = "$Surname, $GivenName" }
	if ([string]::IsNullOrWhiteSpace($UserPrincipalName)) { $UserPrincipalName = "$GivenName.$Surname@$($Domain.DNSRoot)" }
	if ([string]::IsNullOrWhiteSpace($EmailAddress)) { $EmailAddress = "$GivenName.$Surname@$($Domain.DNSRoot)" }

	# Get template user
	$getArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Filter'      = "SamAccountName -eq '$SourceUsername' -or DisplayName -eq '$SourceUsername' -or DistinguishedName -eq '$SourceUsername' -or UserPrincipalName -eq '$SourceUsername'"
		'Properties'  = $copyProperties
	}
	if ($null -ne $DomainAccount) { $getArgs.Add("Credential", $DomainAccount) }
	$source = Get-ADUser @getArgs
	if ($null -eq $source) { throw "Template user '$SourceUsername' not found." }

	# Create new user based on template
	$newArgs = @{
		'ErrorAction'     = 'Stop'
		'Server'          = $Domain.PDCEmulator
		'AuthType'        = $AuthType
		'Instance'        = $source
		'Name'            = $NewUserName
		'UserPrincipalName' = $UserPrincipalName
		'DisplayName'     = $DisplayName
		'GivenName'       = $GivenName
		'Surname'         = $Surname
		'EmailAddress'    = $EmailAddress
		'Path'            = $OUPath
		'SamAccountName'  = $SAMAccountName
		'AccountPassword' = $Password
		'Enabled'         = $true
		'PassThru'        = $true
	}
	if ($null -ne $DomainAccount) { $newArgs.Add("Credential", $DomainAccount) }
	
	$newUser = New-ADUser @newArgs

	# Apply additional settings
	if ($ChangePasswordAtLogon) {
		Set-ADUser -Identity $newUser.SamAccountName -PasswordNeverExpires $false -ChangePasswordAtLogon $true -Server $Domain.PDCEmulator
	}

	# Copy memberships
	if ($CopyGroupMemberships) {
		$groups = Get-ADPrincipalGroupMembership -Identity $source.DistinguishedName -Server $Domain.PDCEmulator | Where-Object SamAccountName -ne "Domain Users"
		if ($null -ne $groups) {
			Add-ADPrincipalGroupMembership -Identity $newUser.SamAccountName -MemberOf $groups -Server $Domain.PDCEmulator
		}
	}

	Write-Output $newUser
} catch {
	Write-Error $_
	exit 1
}
