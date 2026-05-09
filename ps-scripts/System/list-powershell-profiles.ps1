<#
.SYNOPSIS
	Lists the PowerShell profiles
.DESCRIPTION
	This PowerShell script lists the user's PowerShell profiles.
.EXAMPLE
	PS> ./list-powershell-profiles.ps1
		Prio  Profile Name           Location                                                         Existent
		----  ------------           --------                                                         --------
		1     AllUsersAllHosts       /opt/PowerShell/profile.ps1                                      no
		2     AllUsersCurrentHost    /opt/PowerShell/Microsoft.PowerShell_profile.ps1                 no
		3     CurrentUserAllHosts    /home/markus/.config/powershell/profile.ps1                      no
		4     CurrentUserCurrentHost /home/markus/.config/powershell/Microsoft.PowerShell_profile.ps1 yes
.CATEGORY System
#>

#Requires -Version 5.1

function ListProfile { param([int]$prio, [string]$profileName, [string]$Location)
	if (Test-Path "$Location") { $Exists = "yes" } else { $Exists = "no" }
	New-Object PSObject -Property @{ Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); 'Prio'="$prio"; 'Profile Name'="$profileName"; 'Location'="$Location"; 'Exists'="$Exists" }
}

function ListProfiles { 
	ListProfile 1 "AllUsersAllHosts"       $PROFILE.AllUsersAllHosts
	ListProfile 2 "AllUsersCurrentHost"    $PROFILE.AllUsersCurrentHost
	ListProfile 3 "CurrentUserAllHosts"    $PROFILE.CurrentUserAllHosts
	ListProfile 4 "CurrentUserCurrentHost" $PROFILE.CurrentUserCurrentHost
}

try {
	ListProfiles | Format-Table -property Prio,'Profile Name',Exists,Location
	exit 0
} catch {
throw
}
