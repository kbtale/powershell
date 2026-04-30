<#
.SYNOPSIS
	Computers: Creates an Active Directory computer
.DESCRIPTION
	Creates a new computer object in Active Directory.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER Computername
	Name of the Active Directory computer.
.PARAMETER Description
	Description of the computer.
.PARAMETER DisplayName
	Display name of the computer.
.PARAMETER DNSHostName
	Fully qualified domain name (FQDN) of the computer.
.PARAMETER Homepage
	URL of the home page of the computer.
.PARAMETER ManagedBy
	User or group that manages the computer.
.PARAMETER OperationSystem
	Operating system name of the computer.
.PARAMETER Enabled
	Computer is enabled.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution on jumphost without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./New-Computer.ps1 -Computername "COMP01" -OUPath "OU=Computers,DC=contoso,DC=com" -Description "Engineering Workstation"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$Computername,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Description,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DisplayName,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$DNSHostname,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[bool]$Enabled = $true,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$Homepage,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$OperationSystem,

	[Parameter(ParameterSetName = "Local or Remote DC")]
	[Parameter(ParameterSetName = "Remote Jumphost")]
	[string]$ManagedBy,

	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[PSCredential]$DomainAccount,

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
		'ErrorAction' = 'Stop'
		'AuthType'    = $AuthType
		'Name'        = $Computername
		'Server'      = $Domain.PDCEmulator
		'Path'        = $OUPath
		'Confirm'     = $false
	}
	if ($null -ne $DomainAccount) {
		$newArgs.Add("Credential", $DomainAccount)
	}
	
	if ($PSBoundParameters.ContainsKey('Description')) { $newArgs['Description'] = $Description }
	if ($PSBoundParameters.ContainsKey('Enabled')) { $newArgs['Enabled'] = $Enabled }
	if ($PSBoundParameters.ContainsKey('DisplayName')) { $newArgs['DisplayName'] = $DisplayName }
	if ($PSBoundParameters.ContainsKey('DNSHostname')) { $newArgs['DNSHostname'] = $DNSHostname }
	if ($PSBoundParameters.ContainsKey('Homepage')) { $newArgs['Homepage'] = $Homepage }
	if ($PSBoundParameters.ContainsKey('OperationSystem')) { $newArgs['OperatingSystem'] = $OperationSystem }
	if ($PSBoundParameters.ContainsKey('ManagedBy')) { $newArgs['ManagedBy'] = $ManagedBy }

	$cmp = New-ADComputer @newArgs -PassThru
	Write-Output $cmp
} catch {
	Write-Error $_
	exit 1
}
