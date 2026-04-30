<#
.SYNOPSIS
	Computers: Adds computers to Active Directory groups
.DESCRIPTION
	Adds computers to Active Directory groups.
.PARAMETER OUPath
	Specifies the Active Directory path (OU).
.PARAMETER ComputerNames
	Comma separated SAMAccountName, SID, DistinguishedName or GUID of the computers.
.PARAMETER GroupNames
	Comma separated names of the groups to which the computers will be added.
.PARAMETER DomainAccount
	Active Directory Credential for remote execution without CredSSP.
.PARAMETER DomainName
	Name of the Active Directory Domain.
.PARAMETER AuthType
	Specifies the authentication method to use (Basic or Negotiate).
.EXAMPLE
	PS> ./Add-ComputerToGroup.ps1 -ComputerNames "COMP01,COMP02" -GroupNames "Workstations" -OUPath "OU=Computers,DC=contoso,DC=com"
.CATEGORY ActiveDirectory
#>

param(
	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string]$OUPath,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string[]]$ComputerNames,

	[Parameter(Mandatory = $true, ParameterSetName = "Local or Remote DC")]
	[Parameter(Mandatory = $true, ParameterSetName = "Remote Jumphost")]
	[string[]]$GroupNames,

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
	[string[]]$cmpSAMAccountNames = @()
	
	$getCompArgs = @{
		'ErrorAction' = 'Stop'
		'Server'      = $Domain.PDCEmulator
		'AuthType'    = $AuthType
	}
	if ($null -ne $DomainAccount) {
		$getCompArgs.Add("Credential", $DomainAccount)
	}

	# Process computer names (handle both array and potential CSV string)
	$flatComputerNames = foreach ($name in $ComputerNames) {
		if ($name -match ',') { $name.Split(',') } else { $name }
	}

	foreach ($name in $flatComputerNames) {
		if ([string]::IsNullOrWhiteSpace($name)) { continue }
		try {
			$cmp = Get-ADComputer @getCompArgs -Identity $name.Trim() | Select-Object -ExpandProperty SAMAccountName
			$cmpSAMAccountNames += $cmp
		} catch {
			$results += "Computer '$name' not found"
		}
	}
	
	$groupArgs = @{
		'ErrorAction' = 'Stop'
		'AuthType'    = $AuthType
		'Server'      = $Domain.PDCEmulator
	}
	if ($null -ne $DomainAccount) {
		$groupArgs.Add("Credential", $DomainAccount)
	}

	$flatGroupNames = foreach ($name in $GroupNames) {
		if ($name -match ',') { $name.Split(',') } else { $name }
	}

	foreach ($comp in $cmpSAMAccountNames) {
		foreach ($itm in $flatGroupNames) {
			if ([string]::IsNullOrWhiteSpace($itm)) { continue }
			try {
				$grp = Get-ADGroup @groupArgs -Identity $itm.Trim()
				Add-ADGroupMember @groupArgs -Identity $grp -Members $comp
				$results += "Computer '$comp' added to Group '$itm'"
			} catch {
				$results += "Error adding computer '$comp' to Group '$itm': $($_.Exception.Message)"
			}
		}
	}
	
	Write-Output $results
} catch {
	Write-Error $_
	exit 1
}
