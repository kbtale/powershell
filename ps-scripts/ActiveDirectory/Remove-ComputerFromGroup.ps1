<#
.SYNOPSIS
	Computers: Removes computers from an Active Directory group
.DESCRIPTION
	Removes specified computer objects from an Active Directory group.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER GroupName
	Name of the group from which the computers are removed.
.PARAMETER ComputerNames
	Comma separated SID, SAMAccountName, DistinguishedName or GUID of the computers.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Remove-ComputerFromGroup.ps1 -ComputerNames "COMP01" -GroupName "TemporaryAccess" -OUPath "OU=Computers,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$GroupName,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string[]]$ComputerNames,

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
	
	[string[]]$results = @()
	
	$getArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
	}
	$remArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
		'Confirm'     = $false
	}
	if ($null -ne $DomainAccount) {
		$getArgs.Add("Credential", $DomainAccount)
		$remArgs.Add("Credential", $DomainAccount)
	}

	[string[]]$cmpSAMAccountNames = @()
	
	# Process computer names (handle both array and potential CSV string)
	$flatComputerNames = foreach ($name in $ComputerNames) {
		if ($name -match ',') { $name.Split(',') } else { $name }
	}

	foreach ($name in $flatComputerNames) {
		if ([string]::IsNullOrWhiteSpace($name)) { continue }
		try {
			$comp = Get-ADComputer @getArgs -Identity $name.Trim() | Select-Object -ExpandProperty SAMAccountName
			$cmpSAMAccountNames += $comp
		} catch {
			$results += "Computer '$name' not found"
		}
	}
   
	foreach ($cmp in $cmpSAMAccountNames) {
		try {
			$grp = Get-ADGroup @getArgs -Identity $GroupName
			Remove-ADGroupMember @remArgs -Identity $grp -Members $cmp
			$results += "Computer '$cmp' removed from Group '$($grp.Name)'"
		} catch {
			$results += "Error removing computer '$cmp' from Group '$GroupName': $($_.Exception.Message)"
		}
	}
	
	Write-Output $results
} catch {
	Write-Error $_
	exit 1
}
