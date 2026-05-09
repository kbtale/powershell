<#
.SYNOPSIS
	List the public SSH key
.DESCRIPTION
	This PowerShell script lists the user's public SSH key (resides in the ~/.ssh folder).
.EXAMPLE
	PS> ./list-ssh-key.ps1
		✅ Public SSH key is: ssh-ed25519 AAAC3NzaC1lZDINTE5AAAAIKjhD0zlk9HV6OAXVtluUJ5c2BawfetGDLWu0CA1R markus@tux
.CATEGORY System
#>

#Requires -Version 5.1

try {
	if (Test-Path "~/.ssh/id_ed25519.pub") {
		$key = Get-Content "~/.ssh/id_ed25519.pub"
	} elseif (Test-Path "~/.ssh/id_rsa.pub") {
		$key = Get-Content "~/.ssh/id_rsa.pub"	
	} else {
		throw "No public SSH key found - execute 'new-ssh-key.ps1' to create one"
	}
	Write-Host "✅ Public SSH key is: $key"
	exit 0
} catch {
throw
}
