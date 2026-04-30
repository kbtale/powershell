<#
.SYNOPSIS
	Computers: Sets the properties of an Active Directory computer
.DESCRIPTION
	Updates the properties of an existing computer object in Active Directory. Only provided parameters are updated.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Computername
	DistinguishedName, DNSHostName or SamAccountName of the computer.
.PARAMETER DNSHostName
	Specifies the fully qualified domain name (FQDN) of the computer.
.PARAMETER Location
	Specifies the location of the computer.
.PARAMETER Description
	Specifies a description of the computer.
.PARAMETER OperatingSystem
	Specifies an operating system name.
.PARAMETER OSServicePack
	Specifies the name of an operating system service pack.
.PARAMETER OSVersion
	Specifies an operating system version.
.PARAMETER TrustedForDelegation
	Specifies whether an account is trusted for Kerberos delegation.
.PARAMETER AllowDialin
	Specifies the network access permission (Allow Dial-in).
.PARAMETER EnableCallback
	Specifies the Callback options.
.PARAMETER CallbackNumber
	Specifies the Callback number.
.PARAMETER NewSAMAccountName
	The new SAMAccountName of the computer.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER SearchScope
	Specifies the scope of the search (Base, OneLevel, SubTree).
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Set-ComputerProperty.ps1 -Computername "COMP01" -Location "Site-A" -Description "Updated Description" -OUPath "OU=Computers,DC=contoso,DC=com"
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
	[string]$DNSHostName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Location,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Description,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$OperatingSystem,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$OSServicePack,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$OSVersion,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$TrustedForDelegation,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$AllowDialin,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[switch]$EnableCallback,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$CallbackNumber,

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
		if (-not [string]::IsNullOrWhiteSpace($DNSHostName)) { $cmp.DNSHostName = $DNSHostName }
		if (-not [string]::IsNullOrWhiteSpace($Location)) { $cmp.Location = $Location }
		if (-not [string]::IsNullOrWhiteSpace($Description)) { $cmp.Description = $Description }
		if (-not [string]::IsNullOrWhiteSpace($OperatingSystem)) { $cmp.OperatingSystem = $OperatingSystem }
		if (-not [string]::IsNullOrWhiteSpace($OSServicePack)) { $cmp.OperatingSystemServicePack = $OSServicePack }
		if (-not [string]::IsNullOrWhiteSpace($OSVersion)) { $cmp.OperatingSystemVersion = $OSVersion }
		if ($PSBoundParameters.ContainsKey('TrustedForDelegation')) { $cmp.TrustedForDelegation = $TrustedForDelegation }
		
		$setArgs = @{
			'ErrorAction' = 'Stop'
			'AuthType'    = $AuthType
			'Server'      = $Domain.PDCEmulator
		}
		if ($null -ne $DomainAccount) {
			$setArgs.Add("Credential", $DomainAccount)
		}

		Set-ADComputer @setArgs -Instance $cmp
		
		$identArgs = $setArgs.Clone()
		$identArgs['Identity'] = $cmp.SamAccountName

		if ($PSBoundParameters.ContainsKey('AllowDialin')) {
			Set-ADComputer @identArgs -Replace @{msnpallowdialin = $AllowDialin}
		}
		if ($PSBoundParameters.ContainsKey('EnableCallback')) {
			if ($EnableCallback) {
				Set-ADComputer @identArgs -Replace @{msRADIUSServiceType = 4}
			} else {
				Set-ADComputer @identArgs -Remove @{msRADIUSServiceType = 4}
			}
		}
		if (-not [string]::IsNullOrWhiteSpace($CallbackNumber)) {
			Set-ADComputer @identArgs -Replace @{'msRADIUSCallbackNumber' = $CallbackNumber; 'msRADIUSServiceType' = 4}
		}
		if (-not [string]::IsNullOrWhiteSpace($NewSAMAccountName)) {
			Set-ADComputer @identArgs -Replace @{'SAMAccountName' = $NewSAMAccountName}
		}

		Write-Output "Properties for computer '$Computername' updated successfully."
	} else {
		throw "Computer '$Computername' not found in OU '$OUPath'"
	}
} catch {
	Write-Error $_
	exit 1
}
